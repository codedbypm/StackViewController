//
//  StackHandler.swift
//  StackViewController
//
//  Created by Paolo Moroni on 01/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation


/// StackHandler is responsible for storing and updating the view controllers array of a
/// StackViewController instance.
///
/// It supports these operations:
/// - **add** a view controller
/// - **remove** one or more view controllers
/// - **replace** the whole stack with a new one

class StackHandler: ExceptionThrowing {

    private(set) var stack = Stack()

    var root: UIViewController? {
        return stack.first
    }

    var top: UIViewController? {
        return stack.last
    }
    
    init(stack: Stack) {
        guard !stack.hasDuplicates else {
            throwError(.duplicateViewControllers, userInfo: ["stack": stack])
            return
        }

        self.stack = stack
    }

    // MARK: - Public methods

    func push(_ viewControllers: Stack) {
        guard canPush(viewControllers) else { return }
        stack.append(contentsOf: viewControllers)
    }
    
    func popLast(_ count: Int) -> Stack {
        guard canPopLast(count) else { return [] }
        
        let popped = stack.suffix(count)
        stack.removeLast(count)
        return Array(popped)
    }

    @discardableResult
    func popAll() -> Stack {
        return popLast(stack.count)
    }

    func replaceStack(with newStack: Stack) {
        guard canReplaceStack(with: newStack) else { return }
        popAll()
        push(newStack)
    }

    // MARK: - Validation



}

