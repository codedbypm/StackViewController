//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandlerDelegate: class {
    func willStartTransition(using context: TransitionContext)
    func didEndTransition(using context: TransitionContext, completed: Bool)
}

class TransitionHandler {

    weak var delegate: TransitionHandlerDelegate?
    private let transition: Transition
    private weak var stackViewControllerDelegate: StackViewControllerDelegate?
    private let context: TransitionContext
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?

    init(transition: Transition, stackViewControllerDelegate: StackViewControllerDelegate?) {
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

        context.onTransitionFinished = { [weak self] didComplete in
            self?.animationController?.animationEnded?(didComplete)
            self?.transitionFinished(didComplete)
        }
    }

    func performTransition() {
        delegate?.willStartTransition(using: context)

        if context.isInteractive {
            interactionController?.startInteractiveTransition(context)
        } else {
            animationController?.animateTransition(using: context)
        }
    }

    func transitionFinished(_ didComplete: Bool) {
        delegate?.didEndTransition(using: context, completed: didComplete)
        interactionController = nil
        animationController = nil
    }

    func updateInteractiveTransition(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
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

    func stopInteractiveTransition(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let interactionController = interactionController as? InteractivePopAnimator else {
            return
        }
        interactionController.stopInteractiveTransition(gestureRecognizer)
    }
}
