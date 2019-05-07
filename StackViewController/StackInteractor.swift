//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewModelDelegate: class {
    func didReplaceStack(oldStack: Stack, with newStack: Stack)
    func didCreateTransition(_: Transition)
}

public typealias Stack = [UIViewController]

class StackInteractor: ExceptionThrowing {

    weak var delegate: StackViewModelDelegate?
    lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private(set) var stack = Stack()
    private var lastTransition: Transition?

    var topViewController: UIViewController? { return stack.last }

    init(stack: Stack) {
        guard !stack.hasDuplicates else {
            throwError(.duplicateViewControllers, userInfo: ["stack": stack])
            return
        }

        self.stack = stack
    }

    func push(_ stack: Stack, animated: Bool) {
        guard canPush(stack) else { return }

        let from = topViewController
        let to = stack.last

        self.stack.append(contentsOf: stack)

        let transition = Transition(operation: .push,
                                    from: from,
                                    to: to,
                                    containerView: viewControllerWrapperView,
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

    @discardableResult
    private func popToViewController(at index: Int,
                                     animated: Bool,
                                     interactive: Bool = false) -> Stack {
        let poppedCount = stack.endIndex - (index + 1)
        guard canPopLast(poppedCount) else { return [] }

        let from = topViewController
        let to = stack[index]
        let poppedElements = stack.suffix(poppedCount)

        stack.removeLast(poppedCount)

        let transition = Transition(operation: .pop,
                                    from: from,
                                    to: to,
                                    containerView: viewControllerWrapperView,
                                    animated: animated,
                                    interactive: interactive,
                                    undo: { self.stack.append(contentsOf: poppedElements) })

        lastTransition = transition
        delegate?.didCreateTransition(transition)
        return Array(poppedElements)
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
        delegate?.didReplaceStack(oldStack: oldStack, with: newStack)
        
        let transition = Transition(operation: operation,
                                    from: from,
                                    to: to,
                                    containerView: viewControllerWrapperView,
                                    animated: animated,
                                    undo: { self.stack = oldStack })
        lastTransition = transition
        delegate?.didCreateTransition(transition)
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
