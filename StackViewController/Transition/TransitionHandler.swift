//
//  TransitionHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandlingDelegate: class {
    func willStartTransition(_: TransitionContext)
    func didEndTransition(_: TransitionContext, didComplete: Bool)
}

class TransitionHandler: TransitionHandling {

    // MARK: - Internal properties

    static let shared = TransitionHandler()

    weak var delegate: TransitionHandlingDelegate?
    weak var stackViewControllerDelegate: StackViewControllerDelegate?

    // MARK: - Private properties

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private var transitionId: UUID?
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?

    // MARK: - Internal methdos

    func prepareTransition(context: TransitionContext) {
        let animationController = self.animationController(context: context)

        if context.isInteractive {
            let interactionController = self.interactionController(
                animationController: animationController
            )
            performInteractiveTransition(
                context: context,
                animationController: animationController,
                interactionController: interactionController
            )
        } else {
            performTransition(
                context: context,
                animationController: animationController
            )
        }
    }
    
    func performTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning
    ) {

        context.onTransitionFinished = { didComplete in
            animationController.animationEnded?(didComplete)
            self.delegate?.didEndTransition(context, didComplete: didComplete)
            self.animationController = nil
        }

        context.onTransitionCancelled = { _ in
        }

        transitionId = UUID()
        self.animationController = animationController

        if let to = context.viewController(forKey: .to) {
            context.containerView.addSubview(to.view)
        }

        delegate?.willStartTransition(context)

        animationController.animateTransition(using: context)
    }

    func performInteractiveTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning,
        interactionController: UIViewControllerInteractiveTransitioning
    ) {
        delegate?.willStartTransition(context)

        context.onTransitionFinished = { didComplete in
            animationController.animationEnded?(didComplete)
            self.delegate?.didEndTransition(context, didComplete: didComplete)
            self.animationController = nil
            self.interactionController = nil
        }

        transitionId = UUID()
        self.interactionController = interactionController
        interactionController.startInteractiveTransition(context)
    }
}

extension TransitionHandler {

    func defaultAnimationController(
        for operation: StackViewController.Operation
    ) -> Animator {
        switch operation {
        case .pop: return PopAnimator()
        case .push: return PushAnimator()
        case .none: return NoTransitionAnimator()
        }
    }

    func animationController(
        context: TransitionContext
    ) -> UIViewControllerAnimatedTransitioning {
        if let controller = userProvidedAnimationController(
            context: context
            ) {
            return controller
        } else {
            return defaultAnimationController(for: context.operation)
        }
    }

    func userProvidedAnimationController(
        context: TransitionContext
    ) -> UIViewControllerAnimatedTransitioning? {

        guard let from = context.from else { return nil }
        guard let to = context.to else { return nil }
        guard let controller = stackViewControllerDelegate?.animationController(
            for: context.operation,
            from: from,
            to: to
            ) else { return nil }

        return controller
    }

    func interactionController(
        animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning {

        if let interactionController = userProvidedInteractionController(
            animationController: animationController)
        {
            return interactionController
        } else {
            return InteractivePopAnimator(
                animationController: animationController,
                screenEdgePanGestureRecognizer: screenEdgePanGestureRecognizer!
            )
        }
    }

    func userProvidedInteractionController(
        animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return stackViewControllerDelegate?.interactionController(for: animationController)
    }
}

extension TransitionHandler: CustomStringConvertible {

    var description: String {
        return String(describing: type(of: self)).appending(" \(String(describing: transitionId))")
    }
}
