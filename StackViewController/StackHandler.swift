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
    typealias Insertion = CollectionDifference<UIViewController>.Change
    typealias Removal = CollectionDifference<UIViewController>.Change
    typealias Insertions = [CollectionDifference<UIViewController>.Change]
    typealias Removals = [CollectionDifference<UIViewController>.Change]
}

enum StackOperationError: Swift.Error {
    case elementAlreadyOnStack
    case elementNotFound
    case duplicateElements
    case emptyStack
}

typealias StackOperationResult = Result<Stack.Difference, StackOperationError>

class StackHandler: StackHandling, ExceptionThrowing {

    // MARK: - Internal properties

    private(set) var stack = Stack()

    // MARK: - Init

    init() {
    }

    init(stack: Stack) {
        //TODO: handle this guard in a better way
        guard !stack.hasDuplicates else { return }
        self.stack = stack
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController) -> StackOperationResult {
        guard canPush(viewController) else { return .failure(.elementAlreadyOnStack)}
        stack.append(viewController)
        let difference = stack.difference(from: stack.dropLast())
        return .success(difference)
    }

    func pop() -> StackOperationResult {
        let index = stack.endIndex.advanced(by: -2)
        return popToViewController(at: index)
    }

    func popToRoot() -> StackOperationResult {
        return popToViewController(at: stack.startIndex)
    }

    func popToElement(_ element: Stack.Element) -> StackOperationResult {
        guard let index = stack.firstIndex(of: element) else { return .failure(.elementNotFound) }
        return popToViewController(at: index)
    }

    func replaceStack(with newStack: Stack) -> StackOperationResult {
        guard canReplaceStack(with: newStack) else { return .failure(.duplicateElements) }
        let difference = newStack.difference(from: stack)
        stack = newStack
        return .success(difference)
    }

    // MARK: - Private methods

    private func popToViewController(at index: Int) -> StackOperationResult {
        let poppedCount = stack.endIndex - (index + 1)
        guard canPopLast(poppedCount) else { return .failure(.emptyStack) }

        let poppedElements = Array(stack.suffix(poppedCount))
        stack.removeLast(poppedCount)

        let difference = stack.difference(from: (stack + poppedElements))

        return .success(difference)
    }

    private func canPush(_ viewController: UIViewController) -> Bool {
        guard !stack.contains(viewController) else { return false }
        return true
    }

    private func canPopLast(_ count: Int) -> Bool {
        guard (0..<stack.count).contains(count) else { return false }
        return true
    }

    private func canReplaceStack(with newStack: Stack) -> Bool {
        guard !newStack.hasDuplicates else { return false }
        return true
    }
}
