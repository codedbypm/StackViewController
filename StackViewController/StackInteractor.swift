//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public typealias Stack = [UIViewController]

protocol StackInteractorDelegate: class {
    func didAddStackElements(_: Stack)
    func didRemoveStackElements(_: Stack)
    func didReplaceStack(_ oldStack: Stack, with newStack: Stack)

    func stackDidChange(_ change: CollectionDifference<Stack.Element>)
    func didCreateTransition(_: Transition)
}

class StackInteractor: ExceptionThrowing {

    // MARK: - Internal properties

    weak var delegate: StackInteractorDelegate?

    var topViewController: UIViewController? { return stack.last }

    // MARK: - Private properties

    private(set) var stack = Stack() {
        didSet {
            let difference = stack.difference(from: oldValue)
            delegate?.stackDidChange(difference)
        }
    }

    private var lastTransition: Transition?

    // MARK: - Init

    init(stack: Stack) {
        //TODO: handle this guard in a better way
        guard !stack.hasDuplicates else { return }
        self.stack = stack
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController, animated: Bool) {
        push([viewController], animated: animated)
    }

    func push(_ stack: Stack, animated: Bool) {
        guard canPush(stack) else { return }

        let from = topViewController
        let to = stack.last

        self.stack.append(contentsOf: stack)

        let transition = Transition(operation: .push,
                                    from: from,
                                    to: to,
                                    animated: animated,
                                    undo: { self.stack.removeLast() })
        lastTransition = transition
        delegate?.didCreateTransition(transition)
    }

    @discardableResult
    func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        let index = stack.endIndex.advanced(by: -2)
        return popToViewController(at: index, animated: animated, interactive: interactive).first
    }

    func popToRoot(animated: Bool) -> Stack {
        return popToViewController(at: stack.startIndex, animated: animated)
    }

    func popTo(_ viewController: UIViewController, animated: Bool, interactive: Bool = false) -> Stack {
        let index = stack.firstIndex(of: viewController) ?? stack.endIndex
        return popToViewController(at: index, animated: animated)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        guard canReplaceStack(with: newStack) else { return }

        let from = topViewController
        let to = newStack.last
        let operation: StackViewController.Operation

        if let to = to {
            if stack.contains(to) {
                operation = .pop
            } else {
                operation = .push
            }
        } else {
            if from != nil {
                operation = .pop
            } else {
                return
                //                operation = .none
            }
        }

        let oldStack = stack
        stack = newStack
        delegate?.didReplaceStack(oldStack, with: newStack)

        let transition = Transition(operation: operation,
                                    from: from,
                                    to: to,
                                    animated: animated,
                                    undo: { self.stack = oldStack })
        lastTransition = transition
        delegate?.didCreateTransition(transition)
    }

    // MARK: - Private methods

    @discardableResult
    private func popToViewController(at index: Int,
                                     animated: Bool,
                                     interactive: Bool = false) -> Stack {
        let poppedCount = stack.endIndex - (index + 1)
        guard canPopLast(poppedCount) else { return [] }

        let from = topViewController
        let to = stack[index]
        let poppedElements = Array(stack.suffix(poppedCount))

        stack.removeLast(poppedCount)
        delegate?.didRemoveStackElements(poppedElements)

        let transition = Transition(operation: .pop,
                                    from: from,
                                    to: to,
                                    animated: animated,
                                    interactive: interactive,
                                    undo: { self.stack.append(contentsOf: poppedElements) })

        lastTransition = transition
        delegate?.didCreateTransition(transition)
        return Array(poppedElements)
    }

    private func canPush(_ stack: Stack) -> Bool {
        guard !(self.stack + stack).hasDuplicates else { return false }
        return true
    }

    func canPopLast(_ count: Int) -> Bool {
        guard (1..<stack.count).contains(count) else { return false }
        return true
    }

    private func canReplaceStack(with newStack: Stack) -> Bool {
        guard !stack.elementsEqual(newStack) else { return false }
        guard !newStack.hasDuplicates else { return false }
        return true
    }

    func canPopViewControllerInteractively() -> Bool {
        guard canPopLast(1) else { return false }
        return true
    }
}
