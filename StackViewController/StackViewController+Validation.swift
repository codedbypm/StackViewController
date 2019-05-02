//
//  StackViewController+Validation.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension StackHandler {
    
    func canPush(_ viewController: UIViewController) -> Bool {
        return !stack.contains(viewController)
    }

    func canPop() -> Bool {
        return canPop(to: stack.endIndex - 2)
    }

    func canPop(to viewController: UIViewController) -> Bool {
        guard let index = stack.firstIndex(of: viewController) else { return false }
        return canPop(to: index)
    }

    func canPopToRoot() -> Bool {
        return canPop(to: 0)
    }

    func canPop(to index: Int) -> Bool {
        guard ((0..<stack.count).contains(index)) else { return false }
        return true
    }

    func canReplaceStack(with newStack: Stack) -> Bool {
        let stacksAreDifferent = !stack.elementsEqual(newStack) {
            return $0.isEqual($1)
        }

        return stacksAreDifferent
    }

    func canPopInteractively() -> Bool {
        guard canPop() else { return false }
//        guard interactionController == nil else { return false }

        return true
    }
}
