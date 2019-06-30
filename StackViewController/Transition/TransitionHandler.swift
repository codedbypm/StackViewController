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

    var operation: StackViewController.Operation {
        return transitionContext?.operation ?? .none
    }

    // MARK: - Private properties

    private weak var stackViewControllerDelegate: StackViewControllerDelegate?
    private var transitionContext: TransitionContext?
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private let transitionId = UUID()

    // MARK: - Init
    init() {

    }

//    init(operation: StackViewController.Operation,
//         from: UIViewController?,
//         to: UIViewController?,
//         containerView: UIView,
//         animated: Bool,
//         interactive: Bool = false,
//         screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer? = nil) {
//
//        self.screenEdgePanGestureRecognizer = screenEdgePanGestureRecognizer
//
//        transitionContext = TransitionContext(operation: operation,
//                                              from: from,
//                                              to: to,
//                                              containerView: containerView,
//                                              animated: animated,
//                                              interactive: interactive)
//
//        transitionContext?.onTransitionFinished = { [weak self] didComplete in
//            self?.animationController?.animationEnded?(didComplete)
//            self?.transitionFinished(didComplete)
//        }
//
//        transitionContext?.onTransitionCancelled = { _ in
//
//        }
//    }

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    func performTransition(_ context: TransitionContext) {

        delegate?.willStartTransition(context)

        let animationController: UIViewControllerAnimatedTransitioning
        let interactionController: UIViewControllerInteractiveTransitioning?

        if let from = context.from, let to = context.to {
            if let controller = stackViewControllerDelegate?.animationController(for: context.operation, from: from, to: to) {
                animationController = controller
            } else {
                animationController = defaultAnimationController(for: context.operation)
            }
        } else {
            animationController = defaultAnimationController(for: context.operation)
        }
        self.animationController = animationController


        if context.isInteractive {
            if let controller = stackViewControllerDelegate?.interactionController(for: animationController) {
                interactionController = controller
            } else {
                interactionController = InteractivePopAnimator(animationController: animationController,
                                                               screenEdgePanGestureRecognizer: screenEdgePanGestureRecognizer!)
            }
            self.interactionController = interactionController
            interactionController?.startInteractiveTransition(context)
        } else {
            self.interactionController = nil
            animationController.animateTransition(using: context)
        }
    }

    func transitionFinished(_ didComplete: Bool) {
        guard let transitionContext = transitionContext else { return }

        delegate?.didEndTransition(transitionContext, didComplete: didComplete)
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
