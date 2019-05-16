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

    var operation: StackViewController.Operation {
        return transitionContext.operation
    }

    // MARK: - Private properties

    private weak var stackViewControllerDelegate: StackViewControllerDelegate?
    private let transitionContext: TransitionContext
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?
    private let screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private let transitionId = UUID()

    // MARK: - Init

    init(operation: StackViewController.Operation,
         from: UIViewController?,
         to: UIViewController?,
         containerView: UIView,
         animated: Bool,
         interactive: Bool = false,
         screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer? = nil) {

        self.screenEdgePanGestureRecognizer = screenEdgePanGestureRecognizer

        transitionContext = TransitionContext(operation: operation,
                                              from: from,
                                              to: to,
                                              containerView: containerView,
                                              animated: animated,
                                              interactive: interactive)

        transitionContext.onTransitionFinished = { [weak self] didComplete in
            self?.animationController?.animationEnded?(didComplete)
            self?.transitionFinished(didComplete)
        }

        transitionContext.onTransitionCancelled = { _ in

        }
    }

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    func performTransition() {
        delegate?.willStartTransition(using: transitionContext)

        if transitionContext.isAnimated {
            let animationController: UIViewControllerAnimatedTransitioning
            let interactionController: UIViewControllerInteractiveTransitioning?

            if let from = transitionContext.from, let to = transitionContext.to {
                if let controller = stackViewControllerDelegate?.animationController(for: transitionContext.operation, from: from, to: to) {
                    animationController = controller
                } else {
                    animationController = defaultAnimationController(for: transitionContext.operation)
                }
            } else {
                animationController = defaultAnimationController(for: transitionContext.operation)
            }
            self.animationController = animationController


            if transitionContext.isInteractive {
                if let controller = stackViewControllerDelegate?.interactionController(for: animationController) {
                    interactionController = controller
                } else {
                    interactionController = InteractivePopAnimator(animationController: animationController,
                                                                   screenEdgePanGestureRecognizer: screenEdgePanGestureRecognizer!)
                }
                self.interactionController = interactionController
                interactionController?.startInteractiveTransition(transitionContext)
            } else {
                self.interactionController = nil
                animationController.animateTransition(using: transitionContext)
            }
        } else {
            delegate?.willStartTransition(using: transitionContext)
            let animator = defaultAnimationController(for: transitionContext.operation)
            animator.prepareTransition(using: transitionContext)
            animator.transitionAnimations(using: transitionContext)()
            animator.transitionCompletion(using: transitionContext)(.end)
        }
    }

    func transitionFinished(_ didComplete: Bool) {
        delegate?.didEndTransition(using: transitionContext, didComplete: didComplete)
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
        return String(describing: type(of: self)).appending(" \(transitionId)")
    }
}
