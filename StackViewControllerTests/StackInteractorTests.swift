//
//  StackInteractorTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 03/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class StackInteractorTests: XCTestCase {
    var sut: StackInteractor!

    override func setUp() {
        sut = StackInteractor(stack: StackViewController.knownViewControllers)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Inner helper class

    class InteractorDelegate: StackInteractorDelegate {
        var change: CollectionDifference<UIViewController>?
        var didCallStackDidChange = false
        func stackDidChange(_ change: CollectionDifference<Stack.Element>) {
            didCallStackDidChange = true
            self.change = change
        }
    }

    // MARK: - push(_ : UIViewController, animated: Bool)

    func testThat_whenPushingAViewController_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let currentStack = sut.stack
        let pushedViewController = UIViewController()

        // Act
        sut.push(pushedViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, currentStack + [pushedViewController])
    }

    func testThat_whenPushingAViewController_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let interactorDelegate = InteractorDelegate()
        sut.delegate = interactorDelegate

        let currentStack = sut.stack
        let pushedViewController = UIViewController()
        let insertions: [CollectionDifference<Stack.Element>.Change] = [
            .insert(offset: currentStack.endIndex, element: pushedViewController, associatedWith: nil)
        ]
        let expectedDifference = CollectionDifference<UIViewController>.init(insertions)

        // Act
        sut.push(pushedViewController, animated: true)

        // Assert

        XCTAssertTrue(sut.delegate === interactorDelegate)
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.change, expectedDifference)
    }

    func testThat_whenPushingAViewControllerAlreadyPresentInTheStack_theCurrentStackIsNotChanged() {
        // Arrange
        let currentStack = sut.stack
        let pushedViewController = StackViewController.knwownViewControllerA

        // Act
        sut.push(pushedViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, currentStack)
    }

    // MARK: - push(_: Stack, animated: Bool)

    func testThat_whenPushingAValidStack_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let currentStack = sut.stack
        let pushedStack = [UIViewController()]

        // Act
        sut.push(pushedStack, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, currentStack + pushedStack)
    }

    func testThat_whenPushingAValidStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let interactorDelegate = InteractorDelegate()
        sut.delegate = interactorDelegate

        let currentStack = sut.stack
        let pushedViewController = UIViewController()
        let insertions: [CollectionDifference<Stack.Element>.Change] = [
            .insert(offset: currentStack.endIndex, element: pushedViewController, associatedWith: nil)
        ]
        let expectedDifference = CollectionDifference<UIViewController>.init(insertions)

        // Act
        sut.push([pushedViewController], animated: true)

        // Assert

        XCTAssertTrue(sut.delegate === interactorDelegate)
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.change, expectedDifference)
    }

    func testThat_whenPushingAStackResultingInANewStackWithDuplicates_theCurrentStackIsNotChanged() {
        // Arrange
        let currentStack = sut.stack
        let pushedStack = [StackViewController.knwownViewControllerA]

        // Act
        sut.push(pushedStack, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, currentStack)
    }

    // MARK: - pop(animated:, interactive: Bool) -> UIViewController?

    func testThat_whenPoppingAViewController_thisIsRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Arrange
        let currentStack = sut.stack

        // Act
        let poppedViewController = sut.pop(animated: true)

        // Assert
        XCTAssertTrue(poppedViewController === currentStack.last)
        XCTAssertEqual(sut.stack, currentStack.dropLast())
    }

    func testThat_whenPoppingAViewController_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let interactorDelegate = InteractorDelegate()
        sut.delegate = interactorDelegate

        let currentStack = sut.stack
        guard let poppedViewController = currentStack.last else {
            XCTFail("The stack should contain at least 2 view controllers")
            return
        }
        let removals: [CollectionDifference<Stack.Element>.Change] = [
            .remove(offset: (currentStack.endIndex - 1), element: poppedViewController, associatedWith: nil)
        ]
        let expectedDifference = CollectionDifference<UIViewController>.init(removals)

        // Act
        sut.pop(animated: true)

        // Assert

        XCTAssertTrue(sut.delegate === interactorDelegate)
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.change, expectedDifference)
    }

    func testThat_whenTheStackContainsOnlyOneElement_whenPoppingAViewController_theCurrentStackIsNotChangedAndTheMethodReturnsNil() {
        // Arrange
        let oneElementStack = [StackViewController.knwownViewControllerA]
        sut = StackInteractor(stack: oneElementStack)

        // Act
        let poppedViewController = sut.pop(animated: true)

        // Assert
        XCTAssertNil(poppedViewController)
        XCTAssertEqual(sut.stack, oneElementStack)
    }

    // MARK: - popToRoot(animated: Bool) -> Stack

    func testThat_whenPoppingToRoot_allElementsAfterRootAreRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Arrange
        let currentStack = sut.stack

        // Act
        let poppedViewControllers = sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(poppedViewControllers, Array(currentStack.dropFirst()))
        XCTAssertEqual(sut.stack, [currentStack.first])
    }

    func testThat_whenPoppingToRoot_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let interactorDelegate = InteractorDelegate()
        sut.delegate = interactorDelegate

        let currentStack = sut.stack
        let poppedViewControllers = Array(currentStack.suffix(2))
        let removals: [CollectionDifference<Stack.Element>.Change] = [
            .remove(offset: (currentStack.endIndex - 1), element: poppedViewControllers[1], associatedWith: nil),
            .remove(offset: (currentStack.endIndex - 2), element: poppedViewControllers[0], associatedWith: nil)
        ]
        let expectedDifference = CollectionDifference<UIViewController>.init(removals)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertTrue(sut.delegate === interactorDelegate)
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.change, expectedDifference)
    }

    func testThat_whenTheStackContainsOnlyOneElement_whenPoppingToRoot_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let oneElementStack = [StackViewController.knwownViewControllerA]
        sut = StackInteractor(stack: oneElementStack)

        // Act
        let poppedViewControllers = sut.popToRoot(animated: true)

        // Assert
        XCTAssertTrue(poppedViewControllers.isEmpty)
        XCTAssertEqual(sut.stack, oneElementStack)
    }
    
    // MARK: - popTo(_: UIViewController, animated: Bool, interactive: Bool) -> Stack

    func testThat_whenPoppingToAViewControllerAlreadyOnTheStack_allElementsAfterThatViewControllerAreRemovedFromTheCurrentStackAndReturnedToTheCaller() {
        // Arrange
        let currentStack = sut.stack
        let targetViewController = StackViewController.knwownViewControllerB

        // Act
        let poppedViewControllers = sut.popTo(targetViewController, animated: true)

        // Assert
        XCTAssertEqual(poppedViewControllers, Array(currentStack.dropFirst(2)))
        XCTAssertEqual(sut.stack, currentStack.dropLast())
    }

    func testThat_whenPoppingToAViewControllerAlreadyOnTheStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let interactorDelegate = InteractorDelegate()
        sut.delegate = interactorDelegate

        let currentStack = sut.stack
        let targetViewController = StackViewController.knwownViewControllerB
        let poppedViewControllers = Array(currentStack.suffix(1))
        let removals: [CollectionDifference<Stack.Element>.Change] = [
            .remove(offset: (currentStack.endIndex - 1), element: poppedViewControllers[0], associatedWith: nil),
        ]
        let expectedDifference = CollectionDifference<UIViewController>.init(removals)

        // Act
        sut.popTo(targetViewController, animated: true)

        // Assert
        XCTAssertTrue(sut.delegate === interactorDelegate)
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.change, expectedDifference)
    }

    func testThat_whenPoppingToAViewControllerWhichIsNotOnTheStack_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let targetViewController = UIViewController()

        // Act
        let poppedViewControllers = sut.popTo(targetViewController, animated: true)

        // Assert
        XCTAssertTrue(poppedViewControllers.isEmpty)
        XCTAssertEqual(sut.stack, StackViewController.knownViewControllers)
    }
}


extension StackInteractorDelegate {
    func didAddStackElements(_: Stack) {}
    func didRemoveStackElements(_: Stack) {}
    func didReplaceStack(_ oldStack: Stack, with newStack: Stack) {}

    func stackDidChange(_ change: CollectionDifference<Stack.Element>) {}
    func didCreateTransition(_: Transition) {}
}
