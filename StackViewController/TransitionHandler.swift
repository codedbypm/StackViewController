//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandlerDelegate: class {
    func willStartTransition(using _: TransitionContext)
    func didEndTransition(using _: TransitionContext, didComplete: Bool)
}

class TransitionHandler {

    // MARK: - Internal properties

    weak var delegate: TransitionHandlerDelegate?

    // MARK: - Private properties

    private let context: TransitionContext
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?

    // MARK: - Init

    init(context: TransitionContext,
         transitioningDelegate: StackViewControllerDelegate?
    ) {
        self.context = context

        if let from = context.viewController(forKey: .from), let to = context.viewController(forKey: .to), let animatioController = transitioningDelegate?.animationController(for: context.operation, from: from, to: to) {
            self.animationController = animatioController
        } else {
            animationController = (context.operation == .push ? PushAnimator() : PopAnimator())
        }

        if context.isInteractive, let animationController = animationController {
            if let interactionController = transitioningDelegate?.interactionController(for: animationController) {
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
        delegate?.didEndTransition(using: context, didComplete: didComplete)
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
}
