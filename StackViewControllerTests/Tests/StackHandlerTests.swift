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
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - push

    func testThat_whenPushingAViewControllerAlreadyInTheStack_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        sut.pushViewController(.middle)

        // Assert
        XCTAssertEqual(sut.stack, .default)
    }

    func testThat_whenPushingAViewControllerNotYetInTheStack_itAppendsItToTheCurrentStack() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        let pushedViewController = UIViewController()

        // Act
        sut.pushViewController(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, .default + [pushedViewController])
    }

    // MARK: - pop

    func testThat_whenPoppingAViewControllerFromAnEmptyStack_itReturnsNil() {
        // Arrange
        sut = StackHandler.withEmptyStack()

        // Act
        let poppedViewController = sut.popViewController()

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingAViewControllerFromAnEmptyStack_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withEmptyStack()

        // Act
        sut.popViewController()

        // Assert
        XCTAssertEqual(sut.stack, [])
    }

    func testThat_whenPoppingAViewControllerFromAStackWithOneElement_itReturnsNil() {
        // Arrange
        sut = StackHandler.withStack([.first])

        // Act
        let poppedViewController = sut.popViewController()

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingAViewControllerFromAStackWithOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withStack([.first])

        // Act
        sut.popViewController()

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    func testThat_whenPoppingAViewControllerFromAStackWithMoreThanOneElement_itReturnsTheLastViewController() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        let poppedViewController = sut.popViewController()

        // Assert
        XCTAssertEqual(poppedViewController, .last)
    }

    func testThat_whenPoppingAViewControllerFromAStackWithMoreThanOneElement_itUpdatesTheStack() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        sut.popViewController()

        // Assert
        XCTAssertEqual(sut.stack, [.first, .middle])
    }

    // MARK: - popToRoot

    func testThat_whenPoppingToRootFromEmptyStack_itReturnsNil() {
        // Arrange
        sut = StackHandler.withEmptyStack()

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertNil(poppedViewControllers)
    }

    func testThat_whenPoppingToRootFromEmptyStack_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withEmptyStack()

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, [])
    }

    func testThat_whenPoppingToRootFromAStackWithOneElement_itReturnsNil() {
        // Arrange
        sut = StackHandler.withStack([.first])

        // Act
        let poppedViewController = sut.popToRoot()

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingToRootFromAStackWithOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withStack([.first])

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    func testThat_whenPoppingToRootFromAStackWithMoreThanOneElement_itReturnsThePoppedViewControllers() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertEqual(poppedViewControllers, [.middle, .last])
    }

    func testThat_whenPoppingToRootFromAStackWithMoreThanOneElement_itUpdatesTheStack() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    // MARK: - pop(to: )

    func testThat_whenPoppingToViewControllerFromEmptyStack_itReturnsNil() {
        // Arrange
        sut = StackHandler.withEmptyStack()

        // Act
        let poppedViewControllers = sut.pop(to: UIViewController())

        // Assert
        XCTAssertNil(poppedViewControllers)
    }

    func testThat_whenPoppingToViewControllerFromEmptyStack_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withEmptyStack()

        // Act
        sut.pop(to: UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, [])
    }

    func testThat_whenPoppingToViewControllerFromAStackWithOneElement_itReturnsNil() {
        // Arrange
        sut = StackHandler.withStack([.first])

        // Act
        let poppedViewController = sut.pop(to: UIViewController())

        // Assert
        XCTAssertNil(poppedViewController)
    }

    func testThat_whenPoppingToViewControllerFromAStackWithOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withStack([.first])

        // Act
        sut.pop(to: UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, [.first])
    }

    func testThat_whenPoppingToViewControllerNotYetInStackWithMoreThanOneElement_itReturnsNil() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        let poppedViewControllers = sut.pop(to: UIViewController())

        // Assert
        XCTAssertNil(poppedViewControllers)
    }

    func testThat_whenPoppingToViewControllerFromAStackWithMoreThanOneElement_itDoesNotChangeTheStack() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        sut.pop(to: UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, .default)
    }

    func testThat_whenPoppingToViewControllerAlreadyInStackWithMoreThanOneElement_itReturnsPoppedViewControllers() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        let poppedViewControllers = sut.pop(to: .middle)

        // Assert
        XCTAssertEqual(poppedViewControllers, [.last])
    }

    func testThat_whenPoppingToViewControllerAlreadyInStackWithMoreThanOneElement_itUpdatesTheStack() {
        // Arrange
        sut = StackHandler.withDefaultStack()

        // Act
        sut.pop(to: .middle)

        // Assert
        XCTAssertEqual(sut.stack, [.first, .middle])
    }

    // MARK: - setStack

    func testThat_whenSettingStackContainingDuplicates_itDoesNotChangeTheStack() {
        // Arrange
        let stack = Stack.distinctElements(6)
        sut = StackHandler.withStack(stack)

        // Act
        sut.setStack([.first, .last, .first, .first])

        // Assert
        XCTAssertEqual(sut.stack, stack)
    }

    func testThat_whenSettingStack_itReplaceTheCurrentStack() {
        // Arrange
        sut = StackHandler.withDistinctElements(6)

        // Act
        sut.setStack(.default)

        // Assert
        XCTAssertEqual(sut.stack, .default)
    }
}
