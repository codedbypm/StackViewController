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

    // MARK: - push(_ : UIViewController, animated: Bool)

    func testThat_whenPushingAViewControllerWhichIsNotInTheStack_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let stack = Stack.distinctElements(2)
        sut = StackHandler(stack: stack)

        let pushedViewController = UIViewController()

        // Act
        sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, stack + [pushedViewController])
    }

    func testThat_whenPushingAViewControllerWhichIsNotInTheStack_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let pushedViewController = UIViewController()

        let expectedStackChanges = (stack + [pushedViewController]).difference(from: stack)

        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)

        // Act
        sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(mockStackHandlerDelegate.didCallStackDidChange, true)
        XCTAssertEqual(mockStackHandlerDelegate.stackDidChangeDifference, expectedStackChanges)
    }

    func testThat_whenPushingAViewControllerWhichIsAlreadyInTheStack_theCurrentStackIsNotChanged() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let pushedViewController = stack[6]

        // Act
        sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, stack)
    }

    // MARK: - pop(animated:, interactive: Bool) -> UIViewController?

    func testThat_whenPoppingAViewControllerFromAStackHavingMoreThanOneElement_thisIsRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Act
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        let poppedViewController = sut.pop()

        // Assert
        XCTAssertEqual(poppedViewController, stack.last)
        XCTAssertEqual(sut.stack, stack.dropLast())
    }

    func testThat_whenPoppingAViewControllerFromAStackHavingMoreThanOneElement_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let expectedStackChanges = stack.dropLast().difference(from: stack)

        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)

        // Act
        let _ = sut.pop()

        // Assert
        XCTAssertEqual(mockStackHandlerDelegate.didCallStackDidChange, true)
        XCTAssertEqual(mockStackHandlerDelegate.stackDidChangeDifference, expectedStackChanges)
    }

    func testThat_whenPoppingAViewControllerFromAStackHavingOnlyOneElement_theCurrentStackIsNotChangedAndTheMethodReturnsNil() {
        // Arrange
        let oneElementStack = Stack.distinctElements(1)
        sut = StackHandler(stack: oneElementStack)

        // Act
        let poppedViewController = sut.pop()

        // Assert
        XCTAssertNil(poppedViewController)
        XCTAssertEqual(sut.stack, oneElementStack)
    }

    // MARK: - popToRoot(animated: Bool) -> Stack

    func testThat_whenPoppingToRoot_allElementsAfterRootAreRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertEqual(poppedViewControllers, Array(stack.dropFirst()))
        XCTAssertEqual(sut.stack, [stack.first])
    }

    func testThat_whenPoppingToRoot_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let expectedStackChanges = stack.dropLast(9).difference(from: stack)

        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)

        // Act
        let _ = sut.popToRoot()

        // Assert
        XCTAssertEqual(mockStackHandlerDelegate.didCallStackDidChange, true)
        XCTAssertEqual(mockStackHandlerDelegate.stackDidChangeDifference, expectedStackChanges)
    }

    func testThat_whenPoppingToRootFromAStackHavingOnlyOneElement_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let oneElementStack = Stack.distinctElements(1)
        sut = StackHandler(stack: oneElementStack)

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertTrue(poppedViewControllers.isEmpty)
        XCTAssertEqual(sut.stack, oneElementStack)
    }
    
    // MARK: - popTo(_: UIViewController, animated: Bool, interactive: Bool) -> Stack

    func testThat_whenPoppingToAViewControllerAlreadyOnTheStack_allElementsAfterThatViewControllerAreRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let targetIndex = 7
        let targetViewController = stack[targetIndex]

        // Act
        let poppedViewControllers = sut.popTo(targetViewController)

        // Assert
        XCTAssertEqual(poppedViewControllers, stack.suffix(2))
        XCTAssertEqual(sut.stack, stack.dropLast(2))
    }

    func testThat_whenPoppingToAViewControllerWhichIsOnTheStack_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let targetIndex = 7
        let targetViewController = stack[targetIndex]

        let expectedStackChanges = stack.dropLast(2).difference(from: stack)

        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)

        // Act
        let _ = sut.popTo(targetViewController)

        // Assert
        XCTAssertEqual(mockStackHandlerDelegate.didCallStackDidChange, true)
        XCTAssertEqual(mockStackHandlerDelegate.stackDidChangeDifference, expectedStackChanges)
    }

    func testThat_whenPoppingToAViewControllerWhichIsNotOnTheStack_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let targetViewController = UIViewController()

        // Act
        let poppedViewControllers = sut.popTo(targetViewController)

        // Assert
        XCTAssertTrue(poppedViewControllers.isEmpty)
        XCTAssertEqual(sut.stack, stack)
    }

    // MARK: - setStack(_: Stack, animated: Bool)

    func testThat_whenReplacingCurrentStackWithSameStack_theStackIsNotChangedAndTheStackDidChangeMethodIsNotInvoked() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let sameStack = stack

        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)

        // Act
        sut.setStack(sameStack)

        // Assert
        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)
        XCTAssertEqual(sut.stack, stack)
    }

    func testThat_whenReplacingCurrentStackWithAStackContainingDuplicates_theStackIsNotChangedAndTheStackDidChangeMethodIsNotInvoked() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let duplicateViewController = UIViewController()
        let duplicatesStack = [duplicateViewController] + Stack.distinctElements(4) + [duplicateViewController]

        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)

        // Act
        sut.setStack(duplicatesStack)

        // Assert
        XCTAssertNil(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertNil(mockStackHandlerDelegate.stackDidChangeDifference)
        XCTAssertEqual(sut.stack, stack)
    }

    func testThat_ReplacingCurrentStackWithAStackContainingDistinctElements_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let mockStackHandlerDelegate = MockStackHandlerDelegate()
        sut.delegate = mockStackHandlerDelegate

        let newStack = Stack.distinctElements(4)

        let expectedStackChanges = newStack.difference(from: stack)

        // Act
        sut.setStack(newStack)

        // Assert
        XCTAssertEqual(mockStackHandlerDelegate.didCallStackDidChange, true)
        XCTAssertEqual(mockStackHandlerDelegate.stackDidChangeDifference, expectedStackChanges)
    }
}
