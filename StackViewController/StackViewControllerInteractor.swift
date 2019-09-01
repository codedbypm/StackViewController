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

    // MARK: - Private properties

    private let stackHandler: StackHandling
    private var transitionHandler: TransitionHandling

    private var undoLastStackChange: (() -> Void)?

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    private let stackOperationProvider: StackOperationProviding

    // MARK: - Init

    init(stackHandler: StackHandling = StackHandler.shared,
         transitionHandler: TransitionHandling = TransitionHandler.shared,
         stackOperationProvider: StackOperationProviding = StackOperationProvider.shared) {
        self.stackHandler = stackHandler
        self.transitionHandler = transitionHandler
        self.stackOperationProvider = stackOperationProvider

        self.transitionHandler.delegate = self
    }

    // MARK: - Internal methods

    func push(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        guard stackHandler.canPushViewController(viewController) else { return }
        replaceStack(stack + [viewController], animated: animated)
    }

    @discardableResult
    func popViewController(
        animated: Bool,
        interactive: Bool = false
    ) -> UIViewController? {
        guard stackHandler.canPopViewController() else { return nil }

        let newStack: Stack = stack.dropLast()
        return replaceStack(newStack, animated: animated).first
    }

    @discardableResult
    func popToRoot(animated: Bool) -> [UIViewController]? {
        guard stackHandler.canPopToRoot() else { return nil }

        let newStack = Array(stack.prefix(1))
        return replaceStack(newStack, animated: animated)
    }

    @discardableResult
    func pop(
        to viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {

        guard stackHandler.canPop(to: viewController) else { return nil }
        let newStack = Array(stack.prefix(while: { $0 != viewController } ) + [viewController])
        return replaceStack(newStack, animated: animated)
    }

    func setStack(
        _ newStack: [UIViewController],
        animated: Bool
    ) {
        guard stackHandler.canSetStack(newStack) else { return }
        replaceStack(newStack, animated: animated)
    }

    @discardableResult
    private func replaceStack(
        _ newStack: [UIViewController],
        animated: Bool
    ) -> Stack {
        
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

        stack.forEach {
            delegate?.prepareRemovingChild($0)
            delegate?.finishRemovingChild($0)
        }

        let removed = stackHandler.setStack(newStack)

        newStack.dropLast().forEach {
            delegate?.prepareAddingChild($0)
            delegate?.finishAddingChild($0)
        }

        newStack.suffix(1).forEach {
            delegate?.prepareAddingChild($0)
        }

        guard delegate?.isInViewHierarchy == true else { return removed }

        transitionHandler.prepareTransition(context: transitionContext)

        return removed
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

    // MARK: - View appearance events

    func viewWillAppear(_ animated: Bool) {
        guard let topViewController = topViewController else { return }
        delegate?.prepareAppearance(of: topViewController, animated: animated)
    }

    func viewDidAppear(_ animated: Bool) {
        guard let topViewController = topViewController else { return }
        delegate?.finishAppearance(of: topViewController)
        delegate?.finishAddingChild(topViewController)
    }

    func viewWillDisappear(_ animated: Bool) {
        guard let topViewController = topViewController else { return }
        delegate?.prepareDisappearance(of: topViewController, animated: animated)
    }

    func viewDidDisappear(_ animated: Bool) {
        guard let topViewController = topViewController else { return }
        delegate?.finishAppearance(of: topViewController)
//        // TODO: Maybe this needs to be called?
//        delegate?.finishRemovingChild(topViewController)

    }


}

// MARK: - TransitionHandlingDelegate

extension StackViewControllerInteractor: TransitionHandlingDelegate {

    func willStartTransition(_ context: TransitionContext) {
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
}

private extension StackViewControllerInteractor {

    func notifyControllerAboutStackChanges(_ difference: Stack.Difference) {
        let removed = difference.removals.compactMap { change -> UIViewController? in
            if case let .remove(_, element, _) = change { return element }
            else { return nil }
        }
        notifyControllerOfRemovals(removed)

        let inserts = difference.insertions.compactMap { change -> UIViewController? in
            if case let .insert(_, element, _) = change { return element }
            else { return nil }
        }
        notifyControllerOfInsertions(inserts)
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

    func sendViewControllerContainmentBeginEvents(using context: TransitionContext) {
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
