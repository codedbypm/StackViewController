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

    func testThat_whenStackHasMoreThanOneElement_andPopIsCalled_resultContainsTheDifference() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)
        let expectedDifference = stack.dropLast().difference(from: stack)

        // Act
        let result = sut.pop()

        // Assert
        XCTAssertEqual(expectedDifference, try? result.get())
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

    func testThat_whenStackIsEmpty_andPopIsCalled_resultIsErrorEmptyStack() {
        // Arrange
        let stack = Stack.distinctElements(0)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.pop()

        // Assert
        XCTAssertThrowsError(try result.get(), "") { error in
            XCTAssertTrue(error is StackOperationError)
            XCTAssertTrue((error as? StackOperationError) == StackOperationError.emptyStack)
        }
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

    func testThat_whenStackHasMoreThanOneElement_andPopToRootIsCalled_resultContainsTheDifference() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)
        let expectedDifference = stack.prefix(1).difference(from: stack)

        // Act
        let result = sut.popToRoot()

        // Assert
        XCTAssertEqual(expectedDifference, try? result.get())
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

    // MARK: - popToElement(_: Stack.Element) -> Stack

    func testThat_whenElementIsOnTheStack_resultIsSuccess() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)
        let targetIndex = 2
        let targetElement = stack[targetIndex]

        // Act
        let result = sut.popToElement(targetElement)

        // Assert
        XCTAssertNoThrow(try result.get())
    }

    func testThat_whenElementIsOnTheStack_andStackHasOneElement_resultContainsEmptyStack() {
        // Arrange
        let stack = Stack.distinctElements(1)
        sut = StackHandler(stack: stack)
        let targetIndex = 0
        let targetElement = stack[targetIndex]

        // Act
        let result = sut.popToElement(targetElement)

        // Assert
        do {
            let poppedStack = try result.get()
            XCTAssertTrue(poppedStack.isEmpty)
        }
        catch {
            XCTFail()
        }
    }

    func testThat_whenElementIsOnTheStack_andStackHasMoreThanOneElement_resultContainsTheDifference() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)
        let targetIndex = 2
        let targetElement = stack[targetIndex]

        let expectedDifference = stack.prefix(3).difference(from: stack)

        // Act
        let result = sut.popToElement(targetElement)

        // Assert
        XCTAssertEqual(expectedDifference, try? result.get())
    }

    func testThat_whenElementIsNotOnTheStack_resultIsErrorElementNotFound() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        let result = sut.popToElement(UIViewController())

        // Assert
        XCTAssertThrowsError(try result.get(), "") { error in
            XCTAssertTrue(error is StackOperationError)
            XCTAssertTrue((error as? StackOperationError) == StackOperationError.elementNotFound)
        }
    }

    func testThat_whenElementIsNotOnTheStack_theStackIsNotChanged() {
        // Arrange
        let stack = Stack.distinctElements(4)
        sut = StackHandler(stack: stack)

        // Act
        _ = sut.popToElement(UIViewController())

        // Assert
        XCTAssertEqual(sut.stack, stack)
    }

    // MARK: - replaceStack(with: Stack)

    func testThat_whenNewStackContainsDuplicates_resultIsErrorDuplicateElements() {
        // Arrange
        let stack = Stack.distinctElements(3)
        sut = StackHandler(stack: stack)

        let duplicateViewController = UIViewController()
        let duplicatesStack = [duplicateViewController] + Stack.distinctElements(1) + [duplicateViewController]

        // Act
        let result = sut.replaceStack(with: duplicatesStack)

        // Assert
        XCTAssertThrowsError(try result.get(), "") { error in
            XCTAssertTrue(error is StackOperationError)
            XCTAssertTrue((error as? StackOperationError) == StackOperationError.duplicateElements)
        }
    }

    func testThat_whenNewStackContainsNoDuplicates_resultIsSuccess() {
        // Arrange
        let stack = Stack.distinctElements(3)
        sut = StackHandler(stack: stack)

        let newStack = Stack.distinctElements(6)

        // Act
        let result = sut.replaceStack(with: newStack)

        // Assert
        XCTAssertNoThrow(try result.get())
    }
}
