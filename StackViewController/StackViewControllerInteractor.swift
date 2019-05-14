//
//  StackViewControllerInteractor.swift
//  StackViewController
//
//  Created by Paolo Moroni on 11/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewControllerInteractorDelegate: UIViewController {
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

class StackViewControllerInteractor: StackHandlerDelegate  {

    // MARK: - Internal properties

    weak var delegate: StackViewControllerInteractorDelegate?
    weak var stackViewControllerDelegate: StackViewControllerDelegate?

    var stack: Stack { return stackHandler.stack }
    
    var topViewController: UIViewController? { return stack.last }

    lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    // MARK: - Private properties

    private let stackHandler: StackHandler

    private var transitionContext: TransitionContext?

    private var transitionHandler: TransitionHandler?

    private var undoLastStackChange: (() -> Void)?

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    // MARK: - Init

    init(stackHandler: StackHandler) {
        self.stackHandler = stackHandler
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController, animated: Bool) {
        push([viewController], animated: animated)
    }

    func push(_ stack: Stack, animated: Bool) {
        transitionHandler = TransitionHandler(operation: .push,
                                              from: topViewController,
                                              to: stack.last,
                                              containerView: viewControllerWrapperView,
                                              animated: animated)
        stackHandler.push(stack)
    }

    @discardableResult
    func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        transitionHandler = TransitionHandler(operation: .pop,
                                              from: topViewController,
                                              to: stack.dropLast().last,
                                              containerView: viewControllerWrapperView,
                                              animated: animated,
                                              interactive: interactive,
                                              screenEdgePanGestureRecognizer: screenEdgePanGestureRecognizer)
        return stackHandler.pop()
    }

    func popToRoot(animated: Bool) -> Stack {
        transitionHandler = TransitionHandler(operation: .pop,
                                              from: topViewController,
                                              to: stack.first,
                                              containerView: viewControllerWrapperView,
                                              animated: animated)
        return stackHandler.popToRoot()
    }

    func popTo(_ viewController: UIViewController, animated: Bool, interactive: Bool = false) -> Stack {
        transitionHandler = TransitionHandler(operation: .pop,
                                              from: topViewController,
                                              to: viewController,
                                              containerView: viewControllerWrapperView,
                                              animated: animated,
                                              interactive: interactive)
        return stackHandler.popTo(viewController)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        let operation = stackOperation(whenReplacing: stack, with: newStack)
        transitionHandler = TransitionHandler(operation: operation,
                                              from: topViewController,
                                              to: newStack.last,
                                              containerView: viewControllerWrapperView,
                                              animated: animated)
        stackHandler.setStack(newStack)
    }

    // MARK: - StackHandlerDelegate

    func transitionUndo(for difference: Stack.Difference) -> (() -> Void)? {
        return { [weak self] in
            guard let self = self else { return }
            guard let invertedDifference = difference.inverted else { return }
            guard let oldStack = self.stack.applying(invertedDifference) else { return }

            self.stackHandler.delegate = nil
            self.stackHandler.setStack(oldStack)
            self.stackHandler.delegate = self
        }
    }

    func stackDidChange(_ difference: Stack.Difference) {
        assert(transitionHandler != nil)

        notifyControllerAboutStackChanges(difference)

        guard let delegate = delegate, delegate.isInViewHierarchy else {
            transitionHandler = nil
            return
        }

        undoLastStackChange = transitionUndo(for: difference)

        transitionHandler?.performTransition()
    }

    // MARK: - TransitionHandlerDelegate

    func willStartTransition(using context: TransitionContext) {
        if let from = context.viewController(forKey: .from) {
            delegate?.prepareDisappearance(of: from, animated: context.isAnimated)
        }
        if let to = context.viewController(forKey: .to) {
            delegate?.prepareAppearance(of: to, animated: context.isAnimated)
        }
    }

    func didEndTransition(using context: TransitionContext, didComplete: Bool) {
        if didComplete {
            if let from = context.viewController(forKey: .from) {
                delegate?.finishDisappearance(of: from)
            }
            if let to = context.viewController(forKey: .to) {
                delegate?.finishAppearance(of: to)
            }

            if let from = context.viewController(forKey: .from) {
                if case .pop = context.operation {
                    delegate?.finishRemovingChild(from)
                }
            }

            if let to = context.viewController(forKey: .to) {
                if case .push = context.operation {
                    delegate?.finishAddingChild(to)
                }
            }
        } else {
            if let from = context.viewController(forKey: .from) {
                delegate?.prepareAppearance(of: from, animated: context.isAnimated)
            }
            if let to = context.viewController(forKey: .to) {
                delegate?.prepareDisappearance(of: to, animated: context.isAnimated)
            }
            if let from = context.viewController(forKey: .from) {
                delegate?.finishAppearance(of: from)
            }
            if let to = context.viewController(forKey: .to) {
                delegate?.finishAppearance(of: to)
            }

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

    // MARK: - Private methods

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

    private func stackOperation(whenReplacing oldStack: Stack, with newStack: Stack) -> StackViewController.Operation {
        let from = topViewController
        let to = newStack.last

        if let to = to {
            if oldStack.contains(to) { return .pop }
            else { return .push }
        } else {
            if from != nil { return .pop }
            else { return .none }
        }
    }
}

public class NoTransitionAnimator: Animator {
    public override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }

    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
}
