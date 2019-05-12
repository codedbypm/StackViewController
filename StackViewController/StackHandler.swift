//
//  StackHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public typealias Stack = [UIViewController]

extension Stack {
    typealias Difference = CollectionDifference<UIViewController>
    typealias Insertions = [CollectionDifference<UIViewController>.Change]
    typealias Removals = [CollectionDifference<UIViewController>.Change]
}

protocol StackHandlerDelegate: class {
    func stackDidChange(_ difference: Stack.Difference)
}

class StackHandler: ExceptionThrowing {

    // MARK: - Internal properties

    weak var delegate: StackHandlerDelegate?

    // MARK: - Private properties

    private(set) var stack = Stack() {
        didSet {
            guard oldValue != stack else { return }

            let difference = stack.difference(from: oldValue)
            delegate?.stackDidChange(difference)
        }
    }

    // MARK: - Init

    init(stack: Stack) {
        //TODO: handle this guard in a better way
        guard !stack.hasDuplicates else { return }
        self.stack = stack
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController) {
        push([viewController])
    }

    func push(_ stack: Stack) {
        guard canPush(stack) else { return }
        self.stack.append(contentsOf: stack)
    }

    @discardableResult
    func pop() -> UIViewController? {
        let index = stack.endIndex.advanced(by: -2)
        return popToViewController(at: index).first
    }

    @discardableResult
    func popToRoot() -> Stack {
        return popToViewController(at: stack.startIndex)
    }

    @discardableResult
    func popTo(_ viewController: UIViewController) -> Stack {
        let index = stack.firstIndex(of: viewController) ?? stack.endIndex
        return popToViewController(at: index)
    }

    func setStack(_ newStack: Stack) {
        guard canReplaceStack(with: newStack) else { return }
        stack = newStack
    }

    // MARK: - Private methods

    private func popToViewController(at index: Int) -> Stack {
        let poppedCount = stack.endIndex - (index + 1)
        guard canPopLast(poppedCount) else { return [] }

        let poppedElements = Array(stack.suffix(poppedCount))
        stack.removeLast(poppedCount)
        
        return poppedElements
    }

    private func canPush(_ stack: Stack) -> Bool {
        guard !(self.stack + stack).hasDuplicates else { return false }
        return true
    }

    private func canPopLast(_ count: Int) -> Bool {
        guard (1..<stack.count).contains(count) else { return false }
        return true
    }

    private func canReplaceStack(with newStack: Stack) -> Bool {
        guard !stack.elementsEqual(newStack) else { return false }
        guard !newStack.hasDuplicates else { return false }
        return true
    }
}
