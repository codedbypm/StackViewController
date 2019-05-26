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

protocol StackHandlerDelegate: class {
    func stackDidChange(_ difference: Stack.Difference)
}

enum StackOperationError: Swift.Error {
    case elementAlreadyOnStack
    case elementNotFound
}

typealias StackOperationResult<T> = Result<T, StackOperationError>

class StackHandler: ExceptionThrowing {

    // MARK: - Internal properties

    weak var delegate: StackHandlerDelegate?

    // MARK: - Private properties

    private(set) var stack = Stack() {
        didSet {
            let difference = stack.difference(from: oldValue)
            delegate?.stackDidChange(difference)
        }
    }

    // MARK: - Init

    init() {
    }

    init(stack: Stack) {
        //TODO: handle this guard in a better way
        guard !stack.hasDuplicates else { return }
        self.stack = stack
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController) -> StackOperationResult<Void> {
        guard canPush(viewController) else { return .failure(.elementAlreadyOnStack)}
        stack.append(viewController)
        return .success(())
    }

    func pop() -> StackOperationResult<UIViewController?> {
        let index = stack.endIndex.advanced(by: -2)
        return .success(popToViewController(at: index).first)
    }

    func popToRoot() -> StackOperationResult<Stack> {
        return .success(popToViewController(at: stack.startIndex))
    }

    func popToElement(_ element: Stack.Element) -> StackOperationResult<Stack> {
        guard let index = stack.firstIndex(of: element) else { return .failure(.elementNotFound) }
        return .success(popToViewController(at: index))
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

    private func canPush(_ viewController: UIViewController) -> Bool {
        guard !stack.contains(viewController) else { return false }
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
