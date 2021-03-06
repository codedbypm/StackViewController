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

/// An instance of StackHandler is responsible for performing stack operations.
///
/// Each operation is safeguarded by sanity checks so users of this class can safely call any of the
/// stack operation methods. If needed, each operation can be tested for success beforehand.
///
/// - note: Popping the last element and inserting duplicates is not allowed
class StackHandler: StackHandling {

    // MARK: - Internal properties

    static let shared = StackHandler()
    
    private(set) var stack = Stack()

    // MARK: - Init

    private init() {}

    // MARK: - pushViewController

    func canPushViewController(_ viewController: UIViewController) -> Bool {
        return !stack.contains(viewController)
    }

    func pushViewController(_ viewController: UIViewController) {
        guard canPushViewController(viewController) else { return }
        stack.append(viewController)
    }

    // MARK: - popViewController

    func canPopViewController() -> Bool {
        return stack.count > 1
    }

    @discardableResult
    func popViewController() -> UIViewController? {
        guard canPopViewController() else { return nil }
        return stack.removeLast()
    }

    // MARK: - popToRoot

    func canPopToRoot() -> Bool {
        return canPopViewController()
    }

    @discardableResult
    func popToRoot() -> [UIViewController]? {
        guard canPopToRoot() else { return nil }
        let poppedViewControllers = stack[1...]
        stack = Array(stack.prefix(1))
        return Array(poppedViewControllers)
    }

    // MARK: - popToViewController

    func canPop(to viewController: UIViewController) -> Bool {
        return canPopViewController() && stack.contains(viewController)
    }

    @discardableResult
    func pop(
        to viewController: UIViewController
    ) -> [UIViewController]? {
        guard canPop(to: viewController) else { return nil }
        guard let index = stack.firstIndex(of: viewController) else { return nil }
        let poppedViewControllers = stack[index.advanced(by: 1)...]
        stack = Array(stack[...index])
        return Array(poppedViewControllers)
    }

    // MARK: - setStack

    func canSetStack(_ newStack: Stack) -> Bool {
        guard !newStack.hasDuplicates else { return false }
        return true
    }

    @discardableResult
    func setStack(_ newStack: [UIViewController]) -> Stack {
        guard canSetStack(newStack) else { return [] }
        let difference = newStack.difference(from: stack)
        stack = newStack

        return difference.compactMap { change -> UIViewController? in
            if case let .remove(_, viewController, _) = change { return viewController }
            else { return nil }
        }
    }
}
