//
//  StackHandlerTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 03/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class StackHandlerTests: XCTestCase {
    var sut: StackHandler!

    override func setUp() {
        super.setUp()
        sut = StackHandler.shared
        sut.setStack([])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - push

    func testThat_whenPushingAViewControllerAlreadyInTheStack_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([.middle])

        XCTAssertEqual(sut.stack, [.middle])

        // Act
        sut.pushViewController(.middle)

        // Assert
        XCTAssertEqual(sut.stack, [.middle])
    }

    func testThat_whenPushingAViewControllerNotYetInTheStack_itAppendsItToTheCurrentStack() {
        // Arrange
        sut.setStack([.middle])

        let pushedViewController = UIViewController()

        // Act
        sut.pushViewController(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, [.middle, pushedViewController])
    }

    // MARK: - pop

    func testThat_whenPoppingAViewControllerFromAnEmptyStack_itReturnsNil() {
        // Arrange
        sut.setStack([])

        // Act
        let poppedViewController = sut.popViewController()

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingAViewControllerFromAnEmptyStack_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([])

        // Act
        sut.popViewController()

        // Assert
        XCTAssertEqual(sut.stack, [])
    }

    func testThat_whenPoppingAViewControllerFromAStackWithOneElement_itReturnsNil() {
        // Arrange
        sut.setStack([.first])

        // Act
        let poppedViewController = sut.popViewController()

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingAViewControllerFromAStackWithOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([.first])

        // Act
        sut.popViewController()

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    func testThat_whenPoppingAViewControllerFromAStackWithMoreThanOneElement_itReturnsTheLastViewController() {
        // Arrange
        sut.setStack(.default)

        // Act
        let poppedViewController = sut.popViewController()

        // Assert
        XCTAssertEqual(poppedViewController, .last)
    }

    func testThat_whenPoppingAViewControllerFromAStackWithMoreThanOneElement_itUpdatesTheStack() {
        // Arrange
        sut.setStack(.default)

        // Act
        sut.popViewController()

        // Assert
        XCTAssertEqual(sut.stack, [.first, .middle])
    }

    // MARK: - popToRoot

    func testThat_whenPoppingToRootFromEmptyStack_itReturnsNil() {
        // Arrange
        sut.setStack([])

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertNil(poppedViewControllers)
    }

    func testThat_whenPoppingToRootFromEmptyStack_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([])

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, [])
    }

    func testThat_whenPoppingToRootFromAStackWithOneElement_itReturnsNil() {
        // Arrange
        sut.setStack([.first])

        // Act
        let poppedViewController = sut.popToRoot()

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingToRootFromAStackWithOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([.first])

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    func testThat_whenPoppingToRootFromAStackWithMoreThanOneElement_itReturnsThePoppedViewControllers() {
        // Arrange
        sut.setStack(.default)

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertEqual(poppedViewControllers, [.middle, .last])
    }

    func testThat_whenPoppingToRootFromAStackWithMoreThanOneElement_itUpdatesTheStack() {
        // Arrange
        sut.setStack(.default)

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    // MARK: - pop(to: )

    func testThat_whenPoppingToViewControllerFromEmptyStack_itReturnsNil() {
        // Arrange
        sut.setStack([])

        // Act
        let poppedViewControllers = sut.pop(to: UIViewController())

        // Assert
        XCTAssertNil(poppedViewControllers)
    }

    func testThat_whenPoppingToViewControllerFromEmptyStack_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([])

        // Act
        sut.pop(to: UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, [])
    }

    func testThat_whenPoppingToViewControllerFromAStackWithOneElement_itReturnsNil() {
        // Arrange
        sut.setStack([.first])

        // Act
        let poppedViewController = sut.pop(to: UIViewController())

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingToViewControllerFromAStackWithOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack([.first])

        // Act
        sut.pop(to: UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    func testThat_whenPoppingToViewControllerNotYetInStackWithMoreThanOneElement_itReturnsNil() {
        // Arrange
        sut.setStack(.default)

        // Act
        let poppedViewControllers = sut.pop(to: UIViewController())

        // Assert
        XCTAssertNil(poppedViewControllers)
    }

    func testThat_whenPoppingToViewControllerFromAStackWithMoreThanOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut.setStack(.default)

        // Act
        sut.pop(to: UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, .default)
    }

    func testThat_whenPoppingToViewControllerAlreadyInStackWithMoreThanOneElement_itReturnsPoppedViewControllers() {
        // Arrange
        sut.setStack(.default)

        // Act
        let poppedViewControllers = sut.pop(to: .middle)

        // Assert
        XCTAssertEqual(poppedViewControllers, [.last])
    }

    func testThat_whenPoppingToViewControllerAlreadyInStackWithMoreThanOneElement_itUpdatesTheStack() {
        // Arrange
        sut.setStack(.default)

        // Act
        sut.pop(to: .middle)

        // Assert
        XCTAssertEqual(sut.stack, [.first, .middle])
    }

    // MARK: - setStack

    func testThat_whenSettingStackContainingDuplicates_itDoesNotChangeTheStack() {
        // Arrange
        let stack = Stack.distinctElements(6)
        sut.setStack(stack)

        // Act
        sut.setStack([.first, .last, .first, .first])

        // Assert
        XCTAssertEqual(sut.stack, stack)
    }

    func testThat_whenSettingStack_itReplaceTheCurrentStack() {
        // Arrange
        sut.setStack(.distinctElements(6))

        // Act
        sut.setStack(.default)

        // Assert
        XCTAssertEqual(sut.stack, .default)
    }
}
