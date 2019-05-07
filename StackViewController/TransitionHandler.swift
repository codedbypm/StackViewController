//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandlerDelegate: class {
    func willStartTransition(_: Transition)
    func didEndTransition(_: Transition, didComplete: Bool)
}

class TransitionHandler {

    weak var delegate: TransitionHandlerDelegate?
    private let transition: Transition
    private weak var stackViewControllerDelegate: StackViewControllerDelegate?
    private let context: TransitionContext
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?

    init(transition: Transition, stackViewControllerDelegate: StackViewControllerDelegate?, screenEdgeGestureRecognizer: ScreenEdgePanGestureRecognizer? = nil) {
        self.transition = transition
        self.stackViewControllerDelegate = stackViewControllerDelegate
        context = TransitionContext(transition: transition, in: transition.containerView)

        if let from = transition.from, let to = transition.to, let animatioController = stackViewControllerDelegate?.animationController(for: transition.operation, from: from, to: to) {
            self.animationController = animatioController
        } else {
            animationController = (transition.operation == .push ? PushAnimator() : PopAnimator())
        }

        if transition.isInteractive, let animationController = animationController {
            if let interactionController = stackViewControllerDelegate?.interactionController(for: animationController) {
                self.interactionController = interactionController
            } else {
                self.interactionController = InteractivePopAnimator(animationController: animationController)
            }
        }

        let selector = #selector(screenEdgeGestureRecognizerDidChangeState(_:))
        screenEdgeGestureRecognizer?.addTarget(self, action: selector)

        context.onTransitionFinished = { [weak self] didComplete in
            self?.animationController?.animationEnded?(didComplete)
            self?.transitionFinished(didComplete)
        }
    }

    func performTransition() {
        delegate?.willStartTransition(transition)

        if context.isInteractive {
            interactionController?.startInteractiveTransition(context)
        } else {
            animationController?.animateTransition(using: context)
        }
    }

    func transitionFinished(_ didComplete: Bool) {
        delegate?.didEndTransition(transition, didComplete: didComplete)
        interactionController = nil
        animationController = nil
    }

    func updateInteractiveTransition(_ gestureRecognizer: ScreenEdgePanGestureRecognizer) {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.updateInteractiveTransition(gestureRecognizer)
    }

    func cancelInteractiveTransition() {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.cancelInteractiveTransition()
    }

    func stopInteractiveTransition(_ gestureRecognizer: ScreenEdgePanGestureRecognizer) {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.stopInteractiveTransition(gestureRecognizer)
    }

    @objc
    func screenEdgeGestureRecognizerDidChangeState(_ recognizer: ScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            updateInteractiveTransition(recognizer)
        case .cancelled:
            cancelInteractiveTransition()
        case .ended:
            stopInteractiveTransition(recognizer)
        case .possible, .failed, .began:
            break
        @unknown default:
            assertionFailure()
        }

    }
}
