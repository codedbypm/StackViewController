//
//  StackHandlerTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 03/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class StackInteractorTests: XCTestCase {
    var sut: StackHandler!
    var mockStackHandlerDelegate: MockStackHandlerDelegate!
    var initialStack = Stack.default

    override func setUp() {
        mockStackHandlerDelegate = MockStackHandlerDelegate()

        sut = StackHandler(stack: initialStack)
        sut.delegate = mockStackHandlerDelegate
    }

    override func tearDown() {
        mockStackHandlerDelegate = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - push(_ : UIViewController, animated: Bool)

    func testThat_whenPushingAViewControllerWhichIsNotInTheStack_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let pushedViewController = UIViewController()

        // Act
        sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, initialStack + [pushedViewController])
    }

    func testThat_whenPushingAViewControllerWhichIsNotInTheStack_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)
        sut.delegate = mockStackHandlerDelegate

        let pushedViewController = UIViewController()

        let expectedStackChanges = (stack + [pushedViewController]).difference(from: stack)

        // Act
        sut.push(pushedViewController)

        // Assert
        XCTAssertTrue(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(mockStackHandlerDelegate.insertions, expectedStackChanges.insertions)
        XCTAssertEqual(mockStackHandlerDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenPushingAViewControllerWhichIsAlreadyInTheStack_theCurrentStackIsNotChanged() {
        // Arrange
        let pushedViewController = Stack.firstViewController

        // Act
        sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, initialStack)
    }

    // MARK: - push(_: Stack, animated: Bool)

    func testThat_whenPushingAStackContainingDistinctElements_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let pushedStack = Stack.distinctElements(3)

        // Act
        sut.push(pushedStack)

        // Assert
        XCTAssertEqual(sut.stack, initialStack + pushedStack)
    }

    func testThat_whenPushingAStackContainingDistinctElements_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)
        sut.delegate = mockStackHandlerDelegate

        let pushedStack = Stack.distinctElements(3)

        let expectedStackChanges = (stack + pushedStack).difference(from: stack)

        // Act
        sut.push(pushedStack)

        // Assert
        XCTAssertTrue(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(mockStackHandlerDelegate.insertions, expectedStackChanges.insertions)
        XCTAssertEqual(mockStackHandlerDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenPushingAStackResultingInANewStackWithDuplicates_theCurrentStackIsNotChanged() {
        // Arrange
        let pushedStack = [Stack.firstViewController, UIViewController()]

        // Act
        sut.push(pushedStack)

        // Assert
        XCTAssertEqual(sut.stack, initialStack)
    }

    // MARK: - pop(animated:, interactive: Bool) -> UIViewController?

    func testThat_whenPoppingAViewController_thisIsRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Act
        let poppedViewController = sut.pop()

        // Assert
        XCTAssertEqual(poppedViewController, initialStack.last)
        XCTAssertEqual(sut.stack, initialStack.dropLast())
    }

    func testThat_whenPoppingAViewController_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)
        sut.delegate = mockStackHandlerDelegate

        let expectedStackChanges = stack.dropLast().difference(from: stack)

        // Act
        sut.pop()

        // Assert
        XCTAssertTrue(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(mockStackHandlerDelegate.insertions, expectedStackChanges.insertions)
        XCTAssertEqual(mockStackHandlerDelegate.removals, expectedStackChanges.removals)
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

        // Act
        let poppedViewControllers = sut.popToRoot()

        // Assert
        XCTAssertEqual(poppedViewControllers, Array(initialStack.dropFirst()))
        XCTAssertEqual(sut.stack, [initialStack.first])
    }

    func testThat_whenPoppingToRoot_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)
        sut.delegate = mockStackHandlerDelegate

        let expectedStackChanges = stack.dropLast(9).difference(from: stack)

        // Act
        sut.popToRoot()

        // Assert
        XCTAssertTrue(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(mockStackHandlerDelegate.insertions, expectedStackChanges.insertions)
        XCTAssertEqual(mockStackHandlerDelegate.removals, expectedStackChanges.removals)
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
        sut.delegate = mockStackHandlerDelegate

        let targetIndex = 7
        let targetViewController = stack[targetIndex]

        let expectedStackChanges = stack.dropLast(2).difference(from: stack)

        // Act
        sut.popTo(targetViewController)

        // Assert
        XCTAssertTrue(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(mockStackHandlerDelegate.insertions, expectedStackChanges.insertions)
        XCTAssertEqual(mockStackHandlerDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenPoppingToAViewControllerWhichIsNotOnTheStack_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let targetViewController = UIViewController()

        // Act
        let poppedViewControllers = sut.popTo(targetViewController)

        // Assert
        XCTAssertTrue(poppedViewControllers.isEmpty)
        XCTAssertEqual(sut.stack, initialStack)
    }

    // MARK: - setStack(_: Stack, animated: Bool)

    func testThat_whenReplacingCurrentStackWithSameStack_theStackIsNotChangedAndTheStackDidChangeMethodIsNotInvoked() {
        // Arrange
        let currentStack = sut.stack
        let sameStack = sut.stack

        // Act
        sut.setStack(sameStack)

        // Assert
        XCTAssertFalse(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(sut.stack, currentStack)
    }

    func testThat_whenReplacingCurrentStackWithAStackContainingDuplicates_theStackIsNotChangedAndTheStackDidChangeMethodIsNotInvoked() {
        // Arrange
        let duplicatesStack = [
            UIViewController(),
            Stack.firstViewController,
            Stack.firstViewController,
            UIViewController()
        ]

        // Act
        sut.setStack(duplicatesStack)

        // Assert
        XCTAssertFalse(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(sut.stack, initialStack)
    }

    func testThat_ReplacingCurrentStackWithAStackContainingDistinctElements_theDelegateReceivesTheInsertionsAndRemovals() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)
        sut.delegate = mockStackHandlerDelegate

        let newStack = Stack.distinctElements(4)

        let expectedStackChanges = newStack.difference(from: stack)

        // Act
        sut.setStack(newStack)

        // Assert
        XCTAssertTrue(mockStackHandlerDelegate.didCallStackDidChange)
        XCTAssertEqual(mockStackHandlerDelegate.insertions, expectedStackChanges.insertions)
        XCTAssertEqual(mockStackHandlerDelegate.removals, expectedStackChanges.removals)
    }
}
