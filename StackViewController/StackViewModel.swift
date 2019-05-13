//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 11/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewModelDelegate: UIViewController {
    func prepareAddingChild(_: UIViewController) // after this sends willMoveToParent self
    func finishAddingChild(_: UIViewController) // after this sends didMoveToParent self

    func prepareRemovingChild(_: UIViewController) // after this sends willMoveToParent nil
    func finishRemovingChild(_: UIViewController) // after this sends didMoveToParent nil
}

class StackViewModel: StackHandlerDelegate, TransitionHandlerDelegate  {

    // MARK: - Internal properties

    weak var delegate: StackViewModelDelegate?
    weak var transitioningDelegate: StackViewControllerDelegate?

    var stack: Stack { return stackHandler.stack }
    
    var topViewController: UIViewController? { return stack.last }

    lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    // MARK: - Private properties

    private let stackHandler: StackHandler

    private var currentTransition: Transition?

    private var transitionHandler: TransitionHandler?

    // MARK: - Init

    init(stackHandler: StackHandler) {
        self.stackHandler = stackHandler
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController, animated: Bool) {
        currentTransition = Transition(operation: .push,
                                       from: topViewController,
                                       to: viewController,
                                       animated: animated)
        stackHandler.push(viewController)
    }

    func push(_ stack: Stack, animated: Bool) {
        currentTransition = Transition(operation: .push,
                                       from: topViewController,
                                       to: stack.last,
                                       animated: animated)
        stackHandler.push(stack)
    }

    @discardableResult
    func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        currentTransition = Transition(operation: .pop,
                                       from: topViewController,
                                       to: stack[stack.endIndex - 2],
                                       animated: animated,
                                       interactive: interactive)
        return stackHandler.pop()
    }

    @discardableResult
    func popToRoot(animated: Bool) -> Stack {
        currentTransition = Transition(operation: .pop,
                                       from: topViewController,
                                       to: stack.first,
                                       animated: animated)
        return stackHandler.popToRoot()
    }

    @discardableResult
    func popTo(_ viewController: UIViewController, animated: Bool, interactive: Bool = false) -> Stack {
        currentTransition = Transition(operation: .pop,
                                       from: topViewController,
                                       to: viewController,
                                       animated: animated,
                                       interactive: interactive)
        return stackHandler.popTo(viewController)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        let operation = stackOperation(whenReplacing: stack, with: newStack)
        currentTransition = Transition(operation: operation,
                                       from: topViewController,
                                       to: newStack.last,
                                       animated: animated)
        stackHandler.setStack(newStack)
    }

    // MARK: - StackHandlerDelegate

    func stackDidChange(_ difference: Stack.Difference) {
        notifyControllerAboutStackChanges(difference)

        currentTransition?.undo = { [weak self] in
            guard let self = self else { return }
            guard let invertedDifference = difference.inverted else { return }
            guard let oldStack = self.stack.applying(invertedDifference) else { return }

            self.stackHandler.delegate = nil
            self.stackHandler.setStack(oldStack)
            self.stackHandler.delegate = self
        }

        if let transition = currentTransition, let delegate = delegate, delegate.isInViewHierarchy {
            let context = TransitionContext(transition: transition, in: viewControllerWrapperView)
            transitionHandler = TransitionHandler(
                context: context,
                transitioningDelegate: transitioningDelegate
            )
            transitionHandler?.delegate = self
            transitionHandler?.performTransition()
        }
    }

    // MARK: - TransitionHandlerDelegate

    func willStartTransition(using _: TransitionContext) {
//        sendInitialViewAppearanceEvents(for: transition)
    }

    func didEndTransition(using _: TransitionContext, didComplete: Bool) {
//        if didComplete  {
//            sendFinalViewAppearanceEvents(for: transition)
//            sendFinalViewControllerContainmentEvents(for: transition)
//        } else {
//            sendInitialViewAppearanceEvents(for: transition, swapElements: true)
//            sendFinalViewAppearanceEvents(for: transition)
//
//            transition.undo?()
//        }
//
//        transitionHandler = nil
//        debugTransitionEnded()
    }
    // MARK: - Actions

    @objc func screenEdgeGestureRecognizerDidChangeState(_
        gestureRecognizer: ScreenEdgePanGestureRecognizer) {

        switch gestureRecognizer.state {
        case .began:
            pop(animated: true, interactive: true)
        case .changed:
            transitionHandler?.updateInteractiveTransition(gestureRecognizer)
        case .ended:
            transitionHandler?.stopInteractiveTransition(gestureRecognizer)
        case .cancelled:
            transitionHandler?.cancelInteractiveTransition()
        case .failed, .possible:
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
