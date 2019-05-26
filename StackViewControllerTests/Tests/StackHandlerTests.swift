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

    // MARK: - push(_ : UIViewController)

    func testThat_whenPushingAViewControllerWhichIsNotInTheStack_resultIsSuccess() {
        // Arrange
        let stack = Stack.distinctElements(2)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.push(UIViewController())
        
        // Assert
        XCTAssertNoThrow(try result.get())
    }

    func testThat_whenPushingAViewControllerWhichIsNotInTheStack_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let stack = Stack.distinctElements(2)
        sut = StackHandler(stack: stack)

        let pushedViewController = UIViewController()

        // Act
        _ = sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, stack + [pushedViewController])
    }

    func testThat_whenPushingAViewControllerWhichIsAlreadyInTheStack_resultIsErrorElementAlreadyOnStack() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let pushedViewController = stack[6]

        // Act
        let result = sut.push(pushedViewController)

        // Assert
        XCTAssertThrowsError(try result.get(), "") { error in
            XCTAssertTrue(error is StackOperationError)
            XCTAssertTrue((error as? StackOperationError) == StackOperationError.elementAlreadyOnStack)
        }
    }

    func testThat_whenPushingAViewControllerWhichIsAlreadyInTheStack_theStackIsNotChanged() {
        // Arrange
        let stack = Stack.distinctElements(10)
        sut = StackHandler(stack: stack)

        let pushedViewController = stack[6]

        // Act
        _ = sut.push(pushedViewController)

        // Assert
        XCTAssertEqual(sut.stack, stack)
    }

    // MARK: - pop() -> UIViewController?

    func testThat_whenStackHasMoreThanOneElement_andPopIsCalled_resultIsSuccess() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.pop()

        // Assert
        XCTAssertNoThrow(try result.get())
    }

    func testThat_whenStackHasMoreThanOneElement_andPopIsCalled_resultContainsThePoppedElement() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.pop()

        // Assert
        XCTAssertEqual(stack.last, try? result.get())
    }

    func testThat_whenStackHasMoreThanOneElement_andPopIsCalled_theElementIsRemovedFromTheStack() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        _ = sut.pop()

        // Assert
        XCTAssertEqual(sut.stack, stack.dropLast())
    }

    func testThat_whenStackHasOneElement_andPopIsCalled_resultContainsNil() {
        // Arrange
        let stack = Stack.distinctElements(1)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.pop()

        // Assert
        XCTAssertNoThrow(try result.get())
        XCTAssertNil(try? result.get())
    }

    func testThat_whenStackHasOneElement_andPopIsCalled_theStackIsNotChanged() {
        // Arrange
        let stack = Stack.distinctElements(1)
        sut = StackHandler(stack: stack)

        // Act
        _ = sut.pop()

        // Assert
        XCTAssertEqual(sut.stack, stack)
    }

    // MARK: - popToRoot() -> Stack

    func testThat_whenStackHasMoreThanOneElement_andPopToRootIsCalled_resultIsSuccess() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.popToRoot()

        // Assert
        XCTAssertNoThrow(try result.get())
    }

    func testThat_whenStackHasMoreThanOneElement_andPopToRootIsCalled_resultContainsThePoppedElements() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.popToRoot()

        // Assert
        XCTAssertEqual(stack.suffix(3), try? result.get())
    }

    func testThat_whenStackHasMoreThanOneElement_andPopToRootIsCalled_theElementsAreRemovedFromTheStack() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        _ = sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, stack.dropLast(3))
    }

    func testThat_whenStackHasOneElement_andPopToRootIsCalled_resultContainsEmptyStack() {
        // Arrange
        let stack = Stack.distinctElements(1)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.popToRoot()

        // Assert
        do {
            let poppedStack = try result.get()
            XCTAssertTrue(poppedStack.isEmpty)
        }
        catch {
            XCTFail()
        }
    }

    func testThat_whenStackHasOneElement_andPopToRootIsCalled_theStackIsNotChanged() {
        // Arrange
        let stack = Stack.distinctElements(1)
        sut = StackHandler(stack: stack)

        // Act
        _ = sut.popToRoot()

        // Assert
        XCTAssertEqual(sut.stack, stack)
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
