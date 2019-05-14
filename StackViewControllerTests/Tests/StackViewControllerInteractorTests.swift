//
//  StackViewControllerInteractorTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class StackViewControllerInteractorTests: XCTestCase {
    var sut: StackViewControllerInteractor!

    override func setUp() {
        super.setUp()

        let stack = Stack.distinctElements(3)
        let stackHandler = StackHandler(stack: stack)
        sut = StackViewControllerInteractor(stackHandler: stackHandler)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
