//
//  StackViewControllerInteractor.swift
//  StackViewController
//
//  Created by Paolo Moroni on 11/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewControllerInteractorDelegate: UIViewController, StackViewControllerDelegate {
    func prepareAddingChild(_: UIViewController)
    func finishAddingChild(_: UIViewController)

    func prepareRemovingChild(_: UIViewController)
    func finishRemovingChild(_: UIViewController)

    func prepareAppearance(of _: UIViewController, animated: Bool)
    func finishAppearance(of _: UIViewController)
    func prepareDisappearance(of _: UIViewController, animated: Bool)
    func finishDisappearance(of _: UIViewController)

    func startInteractivePopTransition()
}

class StackViewControllerInteractor {

    // MARK: - Internal properties

    weak var delegate: StackViewControllerInteractorDelegate?

    var stack: Stack { return stackHandler.stack }
    
    var topViewController: UIViewController? { return stack.last }
    var rootViewController: UIViewController? { return stack.first }

    lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    private(set) var transitionHandler: TransitionHandler?

    // MARK: - Private properties

    private let stackHandler: StackHandling

    private var undoLastStackChange: (() -> Void)?

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    private let stackOperationProvider: StackOperationProviding

    // MARK: - Init

    init(stackHandler: StackHandling,
         stackOperationProvider: StackOperationProviding = StackOperationProvider.shared) {
        self.stackHandler = stackHandler
        self.stackOperationProvider = stackOperationProvider
    }

    // MARK: - Internal methods

    func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        // guard can push else return
        guard stackHandler.canPushViewController(viewController) else { return }

        // prepare transition context
        let transitionContext = TransitionContext(
            operation: .push,
            from: stack.last,
            to: viewController,
            containerView: viewControllerWrapperView,
            animated: animated
        )

        // push on stack
        stackHandler.pushViewController(viewController)

        // execute transition
        performTransition(context: transitionContext)
    }

    @discardableResult
    func popViewController(
        animated: Bool,
        interactive: Bool = false
    ) -> UIViewController? {
        // guard can push else return
        guard stackHandler.canPopViewController() else { return nil }

        // prepare transition context
        let transitionContext = TransitionContext(
            operation: .pop,
            from: stack.last,
            to: stack.suffix(2).first,
            containerView: viewControllerWrapperView,
            animated: animated,
            interactive: interactive
        )

        performTransition(context: transitionContext)

        let poppedViewController = stackHandler.popViewController()
        undoLastStackChange = { [weak self] in
            guard let controller = poppedViewController else { return }
            self?.stackHandler.pushViewController(controller)
        }

        return poppedViewController
    }

    @discardableResult
    func popToRoot(animated: Bool) -> [UIViewController]? {
        guard stackHandler.canPopToRoot() else { return nil }

        // prepare transition context
        let transitionContext = TransitionContext(
            operation: .pop,
            from: stack.last,
            to: stack.first,
            containerView: viewControllerWrapperView,
            animated: animated,
            interactive: false
        )

        let poppedViewControllers = stackHandler.popToRoot()

        performTransition(context: transitionContext)

        return poppedViewControllers
    }

    @discardableResult
    func pop(
        to viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        guard stackHandler.canPop(to: viewController) else { return nil }

        // prepare transition context
        let transitionContext = TransitionContext(
            operation: .pop,
            from: stack.last,
            to: viewController,
            containerView: viewControllerWrapperView,
            animated: animated,
            interactive: false
        )

        let poppedViewControllers = stackHandler.pop(to: viewController)
        if let poppedViewControllers = poppedViewControllers {
            notifyControllerOfRemovals(poppedViewControllers)
        }

        performTransition(context: transitionContext)

        return poppedViewControllers
    }

    func setStack(
        _ newStack: [UIViewController],
        animated: Bool
        ) {
        guard stackHandler.canSetStack(newStack) else { return }

        let operation = stackOperationProvider.stackOperation(
            whenReplacing: stack,
            with: newStack
        )

        // prepare transition context
        let transitionContext = TransitionContext(
            operation: operation,
            from: stack.last,
            to: newStack.last,
            containerView: viewControllerWrapperView,
            animated: animated,
            interactive: false
        )

        stackHandler.setStack(newStack)

        performTransition(context: transitionContext)
    }

    func performTransition(context: TransitionContext) {
        transitionHandler = TransitionHandler(delegate: self)
        let animationController = self.animationController(context: context)

        if context.isInteractive {
            let interactionController = self.interactionController(
                animationController: animationController
            )
            transitionHandler?.performInteractiveTransition(
                context: context,
                animationController: animationController,
                interactionController: interactionController
            )
        } else {
            transitionHandler?.performTransition(
                context: context,
                animationController: animationController
            )
        }
    }

    // MARK: - Actions

    func handleScreenEdgePanGestureRecognizerStateChange(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            screenEdgePanGestureRecognizer = gestureRecognizer
            delegate?.startInteractivePopTransition()
        case .changed, .ended, .cancelled, .failed, .possible:
            break
        @unknown default:
            assertionFailure()
        }
    }
}

// MARK: - TransitionHandlerDelegate

extension StackViewControllerInteractor: TransitionHandlerDelegate {

    func willStartTransition(_ context: TransitionContext) {
        sendBeginTransitionViewContainmentEvents(using: context)
        sendBeginTransitionViewEvents(using: context)
    }

    func didEndTransition(_ context: TransitionContext, didComplete: Bool) {
        if didComplete {
            sendEndTransitionViewEvents(using: context)
            sendEndTransitionViewContainmentEvents(using: context)

        } else {
            sendBeginTransitionViewEvents(using: context)
            sendEndTransitionViewEvents(using: context)

            undoLastStackChange?()
        }
        //        debugTransitionEnded()
        transitionHandler = nil
    }
}

private extension StackViewControllerInteractor {

    func notifyControllerAboutStackChanges(_ difference: Stack.Difference) {
        let removed = difference.removals.compactMap { change -> UIViewController? in
            if case let .insert(_, element, _) = change { return element }
            else { return nil }
        }
        notifyControllerOfRemovals(removed)

        let inserted = difference
            .insertions
            .compactMap { change -> UIViewController? in
                if case let .insert(_, element, _) = change { return element }
                else { return nil }
            }
            notifyControllerOfInsertions(inserted)
    }

    func notifyControllerOfInsertions(_ insertions: Stack) {
        insertions.dropLast().forEach {
            self.delegate?.prepareAddingChild($0)
            self.delegate?.finishAddingChild($0)
        }
        insertions.suffix(1).forEach {
            self.delegate?.prepareAddingChild($0)
        }
    }

    func notifyControllerOfRemovals(_ removals: Stack) {
        removals.dropLast().forEach {
            self.delegate?.prepareRemovingChild($0)
            self.delegate?.finishRemovingChild($0)
        }
        removals.suffix(1).forEach {
            self.delegate?.prepareRemovingChild($0)
        }
    }

    func sendBeginTransitionViewEvents(using context: TransitionContext) {
        if let from = context.from {
            if context.transitionWasCancelled {
                delegate?.prepareAppearance(of: from, animated: context.isAnimated)
            } else {
                delegate?.prepareDisappearance(of: from, animated: context.isAnimated)
            }
        }

        if let to = context.to {
            if context.transitionWasCancelled {
                delegate?.prepareDisappearance(of: to, animated: context.isAnimated)
            } else {
                delegate?.prepareAppearance(of: to, animated: context.isAnimated)
            }
        }
    }

    func sendEndTransitionViewEvents(using context: TransitionContext) {
        if let from = context.from {
            if context.transitionWasCancelled {
                delegate?.finishAppearance(of: from)
            } else {
                delegate?.finishDisappearance(of: from)
            }
        }

        if let to = context.to {
            if context.transitionWasCancelled {
                delegate?.finishDisappearance(of: to)
            } else {
                delegate?.finishAppearance(of: to)
            }
        }
    }

    func sendBeginTransitionViewContainmentEvents(using context: TransitionContext) {
        if let from = context.from, case .pop = context.operation {
            delegate?.prepareRemovingChild(from)
        }
        if let to = context.to, case .push = context.operation {
            delegate?.prepareAddingChild(to)
        }
    }

    func sendEndTransitionViewContainmentEvents(using context: TransitionContext) {
        if let from = context.from, case .pop = context.operation {
            delegate?.finishRemovingChild(from)
        }

        if let to = context.to, case .push = context.operation {
            delegate?.finishAddingChild(to)
        }
    }
}

private extension StackViewControllerInteractor {

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
        guard let controller = delegate?.animationController(
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
        return delegate?.interactionController(for: animationController)
    }
}

public class NoTransitionAnimator: Animator {
    public override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }

    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
}
