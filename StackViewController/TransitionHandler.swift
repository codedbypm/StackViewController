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

    let transition: Transition

    // MARK: - Private properties

    private let context: TransitionContext
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?

    // MARK: - Init

    init(transition: Transition,
         context: TransitionContext,
         animationController: UIViewControllerAnimatedTransitioning,
         interactionController: UIViewControllerInteractiveTransitioning?
    ) {
        self.transition = transition
        self.context = context
        self.animationController = animationController
        self.interactionController = interactionController


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
