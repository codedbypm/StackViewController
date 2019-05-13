//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 11/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewModelDelegate: class {
    func prepareToMoveToParent(for _: UIViewController) // after this sends willMoveToParent self
    func finalizeMoveToParent(for _: UIViewController) // after this sends didMoveToParent self

    func prepareToRemoveFromParent(for _: UIViewController) // after this sends willMoveToParent nil
    func finalizeRemoveFromParent(for _: UIViewController) // after this sends didMoveToParent nil
    func didReplaceStack(_ oldStack: Stack, with newStack: Stack)

    func didCreateTransition(_: Transition)
}

class StackViewModel: StackHandlerDelegate  {

    // MARK: - Internal properties

    weak var delegate: StackViewModelDelegate?

    var stack: Stack { return stackHandler.stack }
    
    var topViewController: UIViewController? { return stack.last }

    // MARK: - Private properties

    private let stackHandler: StackHandler

    private var currentTransition: Transition?
 
    // MARK: - Init

    init(stackHandler: StackHandler) {
        self.stackHandler = stackHandler
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController, animated: Bool) {
        currentTransition = Transition(operation: .push, from: topViewController, animated: animated)
        stackHandler.push(viewController)
    }

    func push(_ stack: Stack, animated: Bool) {
        currentTransition = Transition(operation: .push, from: topViewController, animated: animated)
        stackHandler.push(stack)
    }

    @discardableResult
    func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        currentTransition = Transition(operation: .pop, from: topViewController, animated: animated, interactive: interactive)
        return stackHandler.pop()
    }

    @discardableResult
    func popToRoot(animated: Bool) -> Stack {
        currentTransition = Transition(operation: .pop, from: topViewController, animated: animated)
        return stackHandler.popToRoot()
    }

    @discardableResult
    func popTo(_ viewController: UIViewController, animated: Bool, interactive: Bool = false) -> Stack {
        currentTransition = Transition(operation: .pop, from: topViewController, animated: animated, interactive: interactive)
        return stackHandler.popTo(viewController)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        let operation = stackOperation(whenReplacing: stack, with: newStack)
        currentTransition = Transition(operation: operation, from: topViewController, animated: animated)
        stackHandler.setStack(newStack)
    }

    // MARK: - StackHandlerDelegate

    func stackDidChange(_ difference: Stack.Difference) {
        notifyControllerAboutStackChanges(difference)

        currentTransition?.to = stackHandler.stack.last
        currentTransition?.undo = { [weak self] in
            guard let self = self else { return }
            guard let invertedDifference = difference.inverted else { return }
            guard let oldStack = self.stack.applying(invertedDifference) else { return }

            self.stackHandler.delegate = nil
            self.stackHandler.setStack(oldStack)
            self.stackHandler.delegate = self
        }

        if let transition = currentTransition {
            delegate?.didCreateTransition(transition)
        }
    }

    // MARK: - Private methods

    private func notifyControllerAboutStackChanges(_ difference: Stack.Difference) {
        let insertedViewControllers = difference.insertions.map { $0._element }
        notifyControllerOfInsertions(insertedViewControllers)

        let removedViewControllers = difference.removals.map { $0._element }
        notifyControllerOfRemovals(removedViewControllers)
    }

    private func notifyControllerOfInsertions(_ insertions: Stack) {
        insertions.dropLast().forEach {
            self.delegate?.prepareToMoveToParent(for: $0)
            self.delegate?.finalizeMoveToParent(for: $0)
        }
        insertions.suffix(1).forEach {
            self.delegate?.prepareToMoveToParent(for: $0)
        }
    }

    private func notifyControllerOfRemovals(_ removals: Stack) {
        removals.dropLast().forEach {
            self.delegate?.prepareToRemoveFromParent(for: $0)
            self.delegate?.finalizeRemoveFromParent(for: $0)
        }
        removals.suffix(1).forEach {
            self.delegate?.prepareToRemoveFromParent(for: $0)
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
