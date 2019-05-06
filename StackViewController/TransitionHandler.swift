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
    private var interactiveController: UIViewControllerInteractiveTransitioning?

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
            if let interactiveController = stackViewControllerDelegate?.interactionController(for: animationController) {
                self.interactiveController = interactiveController
            } else {
                self.interactiveController = InteractivePopAnimator(animationController: animationController)
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
            interactiveController?.startInteractiveTransition(context)
        } else {
            animationController?.animateTransition(using: context)
        }
    }

    func transitionFinished(_ didComplete: Bool) {
        delegate?.didEndTransition(using: context, completed: didComplete)
        interactiveController = nil
        animationController = nil
    }
}
