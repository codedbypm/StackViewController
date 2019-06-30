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

class StackViewControllerInteractor: TransitionHandlerDelegate  {

    // MARK: - Internal properties

    weak var delegate: StackViewControllerInteractorDelegate?

    var stack: Stack { return stackHandler.stack }
    
    var topViewController: UIViewController? { return stack.last }
    var rootViewController: UIViewController? { return stack.first }

    lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    // MARK: - Private properties

    private let stackHandler: StackHandling

    private var transitionHandler: TransitionHandling?

    private var undoLastStackChange: (() -> Void)?

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    // MARK: - Init

    init(stackHandler: StackHandling,
         transitionHandler: TransitionHandling = TransitionHandler()) {
        self.stackHandler = stackHandler
        self.transitionHandler = transitionHandler
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
        transitionHandler?.performTransition(transitionContext)
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

        transitionHandler?.performTransition(transitionContext)

        return stackHandler.popViewController()
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

        if let poppedViewControllers = poppedViewControllers {
            notifyControllerOfRemovals(poppedViewControllers)
        }

        transitionHandler?.performTransition(transitionContext)

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

        transitionHandler?.performTransition(transitionContext)

        return poppedViewControllers
    }

    func setStack(
        _ newStack: [UIViewController],
        animated: Bool
        ) {
        guard stackHandler.canSetStack(newStack) else { return }

        let operation = stackOperation(whenReplacing: stack, with: newStack)

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

        //        // Change the stack
        //        guard let difference = try? stackHandler.replaceStack(with: newStack).get() else {
        //            return
        //        }
        //
        //        // Process the changes
        //        processStackChange(difference)
        //
        // Execute the transition
        transitionHandler?.performTransition(transitionContext)
    }

    // MARK: - TransitionHandlerDelegate

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

    func stackOperation(whenReplacing oldStack: Stack, with newStack: Stack) -> StackViewController.Operation {
        let from = topViewController
        let to = newStack.last

        guard from !== to else { return .none }

        if let to = to {
            if oldStack.contains(to) { return .pop }
            else { return .push }
        } else {
            if from != nil { return .pop }
            else { return .none }
        }
    }
}

private extension StackViewControllerInteractor {
    
    // MARK: - Private methods

    private func processStackChange(_ difference: Stack.Difference) {
        guard !difference.isEmpty else {
            return
        }

        notifyControllerAboutStackChanges(difference)
        undoLastStackChange = transitionUndo(for: difference)
    }

    private func beginTransition() {

        //        guard let delegate = delegate, delegate.isInViewHierarchy, transitionHandler?.operation != .none else {
        //            self.transitionHandler = nil
        //            return
        //        }
        //
        //        transitionHandler?.delegate = self
        //        transitionHandler?.performTransition()
    }

    private func transitionUndo(for difference: Stack.Difference) -> (() -> Void)? {
        return nil
        //        return { [weak self] in
        //            guard let self = self else { return }
        //            guard let invertedDifference = difference.inverted else { return }
        //            guard let oldStack = self.stack.applying(invertedDifference) else { return }
        //
        //            _ = self.stackHandler.replaceStack(with: oldStack)
        //        }
    }

    private func notifyControllerAboutStackChanges(_ difference: Stack.Difference) {
        let removedViewControllers = difference.removals.map { $0._element }
        notifyControllerOfRemovals(removedViewControllers)

        let insertedViewControllers = difference.insertions.map { $0._element }
        notifyControllerOfInsertions(insertedViewControllers)
    }

    private func notifyControllerOfInsertions(_ insertions: Stack) {
        insertions.dropLast().forEach {
            self.delegate?.prepareAddingChild($0)
            self.delegate?.finishAddingChild($0)
        }
        insertions.suffix(1).forEach {
            self.delegate?.prepareAddingChild($0)
        }
    }

    private func notifyControllerOfRemovals(_ removals: Stack) {
        removals.dropLast().forEach {
            self.delegate?.prepareRemovingChild($0)
            self.delegate?.finishRemovingChild($0)
        }
        removals.suffix(1).forEach {
            self.delegate?.prepareRemovingChild($0)
        }
    }

    private func sendBeginTransitionViewEvents(using context: TransitionContext) {
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

    private func sendEndTransitionViewEvents(using context: TransitionContext) {
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

    private func sendBeginTransitionViewContainmentEvents(using context: TransitionContext) {
        if let from = context.from, case .pop = context.operation {
            delegate?.prepareRemovingChild(from)
        }
        if let to = context.to, case .push = context.operation {
            delegate?.prepareAddingChild(to)
        }
    }

    private func sendEndTransitionViewContainmentEvents(using context: TransitionContext) {
        if let from = context.from, case .pop = context.operation {
            delegate?.finishRemovingChild(from)
        }

        if let to = context.to, case .push = context.operation {
            delegate?.finishAddingChild(to)
        }
    }

    func animationController(
        context: TransitionContext
        ) -> UIViewControllerAnimatedTransitioning? {

        let animationController: UIViewControllerAnimatedTransitioning

        if let from = context.from, let to = context.to {
            if let controller = delegate?.animationController(for: context.operation, from: from, to: to) {
                animationController = controller
            } else {
                animationController = defaultAnimationController(for: context.operation)
            }
        } else {
            animationController = defaultAnimationController(for: context.operation)
        }

        return animationController
    }

    func defaultAnimationController(for operation: StackViewController.Operation) -> Animator {
        switch operation {
        case .pop: return PopAnimator()
        case .push: return PushAnimator()
        case .none: return NoTransitionAnimator()
        }
    }

    func interactionController(
        animationController: UIViewControllerAnimatedTransitioning
        ) -> UIViewControllerInteractiveTransitioning? {

        let controller = delegate?.interactionController(
            for: animationController
        )

        if let controller = controller {
            return controller
        } else {
            return InteractivePopAnimator(
                animationController: animationController,
                screenEdgePanGestureRecognizer: screenEdgePanGestureRecognizer!
            )
        }
    }
}

public class NoTransitionAnimator: Animator {
    public override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }

    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
}
