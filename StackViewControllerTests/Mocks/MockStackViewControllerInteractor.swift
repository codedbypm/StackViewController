//
//  MockStackViewControllerInteractor.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 14/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackViewControllerInteractor: StackViewControllerInteractor {

    var didCallStackGetter = false
    override var stack: Stack {
        didCallStackGetter = true
        return Stack.default
    }

    var didCallSetStackAnimated = false
    var passedStack: Stack?
    var passedAnimated: Bool?

    override func setStack(_ newStack: Stack, animated: Bool) {
        didCallSetStackAnimated = true
        passedStack = newStack
        passedAnimated = animated
    }
}
