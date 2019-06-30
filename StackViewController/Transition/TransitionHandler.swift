//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandlerDelegate: class {
    func willStartTransition(_: TransitionContext)
    func didEndTransition(_: TransitionContext, didComplete: Bool)
}

class TransitionHandler: TransitionHandling {

    // MARK: - Internal properties

    weak var delegate: TransitionHandlerDelegate?

    // MARK: - Private properties

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private var transitionId: UUID?

    // MARK: - Init
    init() {

    }

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    func performTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning?,
        interactionController: UIViewControllerInteractiveTransitioning?
    ) {
        delegate?.willStartTransition(context)

        let animator: UIViewControllerAnimatedTransitioning
        let interactiveAnimator: UIViewControllerInteractiveTransitioning?

        if let animationController = animationController {
            animator = animationController
        } else {
            animator = defaultAnimationController(for: context.operation)
        }

        if context.isInteractive {
            if let interactionController = interactionController {
                interactiveAnimator = interactionController
            } else {
                interactiveAnimator = InteractivePopAnimator(
                    animationController: animator,
                    screenEdgePanGestureRecognizer: screenEdgePanGestureRecognizer!)
            }
        } else {
            interactiveAnimator = nil
        }

        context.onTransitionFinished = { didComplete in
            animator.animationEnded?(didComplete)
            self.delegate?.didEndTransition(context, didComplete: didComplete)
        }

        context.onTransitionCancelled = { _ in

        }

        if context.isInteractive {
            interactiveAnimator?.startInteractiveTransition(context)
        } else {
            animator.animateTransition(using: context)
        }
        transitionId = UUID()
    }
}

private extension TransitionHandler {
    
    func defaultAnimationController(for operation: StackViewController.Operation) -> Animator {
        switch operation {
        case .pop: return PopAnimator()
        case .push: return PushAnimator()
        case .none: return NoTransitionAnimator()
        }
    }
}

extension TransitionHandler: CustomStringConvertible {

    var description: String {
        return String(describing: type(of: self)).appending(" \(String(describing: transitionId))")
    }
}
