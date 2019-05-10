//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public typealias Stack = [UIViewController]
extension Stack {
    typealias Difference = CollectionDifference<UIViewController>
    typealias Inserts = [CollectionDifference<UIViewController>.Change]
    typealias Removals = [CollectionDifference<UIViewController>.Change]
}

protocol StackInteractorDelegate: class {
    func didAddStackElements(_: Stack)
    func didRemoveStackElements(_: Stack)
    func didReplaceStack(_ oldStack: Stack, with newStack: Stack)

    func stackDidChange(inserts: Stack.Inserts, removals: Stack.Removals)
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
            delegate?.stackDidChange(inserts: difference.insertions,
                                     removals: difference.removals)
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

        self.stack.append(contentsOf: stack)
    }

    @discardableResult
    func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        let index = stack.endIndex.advanced(by: -2)
        return popToViewController(at: index, animated: animated, interactive: interactive).first
    }

    @discardableResult
    func popToRoot(animated: Bool) -> Stack {
        return popToViewController(at: stack.startIndex, animated: animated)
    }

    @discardableResult
    func popTo(_ viewController: UIViewController, animated: Bool, interactive: Bool = false) -> Stack {
        let index = stack.firstIndex(of: viewController) ?? stack.endIndex
        return popToViewController(at: index, animated: animated)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        guard canReplaceStack(with: newStack) else { return }
        stack = newStack
    }

    // MARK: - Private methods

    @discardableResult
    private func popToViewController(at index: Int,
                                     animated: Bool,
                                     interactive: Bool = false) -> Stack {
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

    //TODO: make this private?
    func canPopViewControllerInteractively() -> Bool {
        guard canPopLast(1) else { return false }
        return true
    }
}
