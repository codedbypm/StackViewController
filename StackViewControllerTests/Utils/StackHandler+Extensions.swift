//
//  StackHandler+Extensions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 12/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

extension StackHandler {

    static func withEmptyStack() -> StackHandler {
        return StackHandler(stack: .empty)
    }

    static func withDefaultStack() -> StackHandler {
        return StackHandler(stack: .default)
    }
    
    static func withDistinctElements(_ size: Int) -> StackHandler {
        return StackHandler(stack: Stack.distinctElements(size))
    }

    static func withStack(_ stack: [UIViewController]) -> StackHandler {
        return StackHandler(stack: stack)
    }
}
