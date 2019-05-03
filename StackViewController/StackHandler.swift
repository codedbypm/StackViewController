//
//  StackHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 01/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public typealias Stack = [UIViewController]

protocol StackHandlerDelegate: class {
    func stackDidChange()
}

class StackHandler: ExceptionThrowing {

    private(set) lazy var viewControllerWrapperView = UIView()

    private(set) var currentTransition: Transition? {
        didSet {
            if currentTransition != oldValue, currentTransition != nil {
                delegate?.stackDidChange()
            }
        }
    }

    var topViewController: UIViewController? {
        return stack.last
    }

    weak var delegate: StackHandlerDelegate?

    private(set) var stack = Stack()

    init(stack: Stack) {
        guard !stack.hasDuplicates else {
            throwError(.duplicateViewControllers, userInfo: ["stack": stack])
            return
        }

        self.stack = stack
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        assert(currentTransition == nil)
        guard canPush(viewController) else { return }

        let from = topViewController
        let to = viewController

        stack.append(viewController)
        
        currentTransition = stackTransition(for: .push,
                                            from: from,
                                            to: to,
                                            in: viewControllerWrapperView,
                                            animated: animated,
                                            interactive: false)
    }

    func popViewController(animated: Bool) -> UIViewController? {
        return popToViewController(at: stack.endIndex - 2, animated: animated)?.first
    }

    func popToRootViewController(animated: Bool) -> Stack? {
        return popToViewController(at: stack.startIndex, animated: animated)
    }

    func popToViewController(_ viewController: UIViewController, animated: Bool) -> Stack? {
        guard let targetIndex = stack.firstIndex(of: viewController) else { return nil }
        return popToViewController(at: targetIndex, animated: animated)
    }

    private func popToViewController(at index: Int, animated: Bool) -> Stack? {
        assert(currentTransition == nil)
        guard canPop(to: index) else { return nil }

        let from = topViewController
        let to = stack[index]

        let poppedStack = Array(stack[(index + 1)...])
        let newStack = Array(stack[...index])

        stack = newStack

        currentTransition = stackTransition(for: .pop,
                                            from: from,
                                            to: to,
                                            in: viewControllerWrapperView,
                                            animated: animated,
                                            interactive: false)
        return poppedStack
    }

    func setStack(_ newStack: Stack, animated: Bool, interactive: Bool = false) {
        assert(currentTransition == nil)

        guard canReplaceStack(with: newStack) else { return }

        let operation: StackViewController.Operation
        let from = topViewController
        let to = newStack.last

        if newStack.isEmpty {
            operation = .pop
            stack.forEach {
                $0.willMove(toParent: nil)
                $0.removeFromParent()
                $0.didMove(toParent: nil)
            }
        } else if stack.isEmpty {
            operation = .push
            newStack.forEach {

                $0.didMove(toParent: nil)
            }
        } else if let to = newStack.last, stack.contains(to) {
            operation = .pop
        } else {
            operation = .push
        }


        stack = newStack
        currentTransition = stackTransition(for: operation,
                                            from: from,
                                            to: to,
                                            in: viewControllerWrapperView,
                                            animated: animated,
                                            interactive: false)
    }

    func endStackTransition() {
        currentTransition = nil
    }
}

