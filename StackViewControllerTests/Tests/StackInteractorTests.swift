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
    var interactorDelegate: InteractorDelegate!
    var initialStack = StackViewController.knownViewControllers

    override func setUp() {
        interactorDelegate = InteractorDelegate()

        sut = StackInteractor(stack: initialStack)
        sut.delegate = interactorDelegate
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Inner helper class

    class InteractorDelegate: StackInteractorDelegate {
        var inserts: Stack.Inserts = []
        var removals: Stack.Removals = []
        var didCallStackDidChange = false
        func stackDidChange(inserts: Stack.Inserts, removals: Stack.Removals) {
            self.inserts = inserts
            self.removals = removals
            self.didCallStackDidChange = true
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

    func testThat_whenPushingANonDuplicateViewController_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let pushedViewController = UIViewController()
        let testScenario: Scenario = .pushNonDuplicate(pushedViewController)
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.push(pushedViewController, animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.inserts, expectedStackChanges.inserts)
        XCTAssertEqual(interactorDelegate.removals, expectedStackChanges.removals)
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

    func testThat_whenPushingAValidStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let pushedStack = [UIViewController(), UIViewController()]
        let testScenario: Scenario = .pushStackWithoutDuplicates(pushedStack)
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.push(pushedStack, animated: true)

        // Assert

        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.changes, expectedDifference)
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
        XCTAssertEqual(poppedViewController, currentStack.last)
        XCTAssertEqual(sut.stack, currentStack.dropLast())
    }

    func testThat_whenPoppingAViewController_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let currentStack = sut.stack
        guard let poppedViewController = currentStack.last else {
            XCTFail("The stack should contain at least 2 view controllers")
            return
        }
        let removals: [Stack.Difference.Change] = [
            .remove(offset: (currentStack.endIndex - 1), element: poppedViewController, associatedWith: nil)
        ]
        let expectedDifference = Stack.Difference.init(removals)

        // Act
        sut.pop(animated: true)

        // Assert

        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.changes, expectedDifference)
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
        let currentStack = sut.stack
        let poppedViewControllers = Array(currentStack.suffix(2))
        let removals: [Stack.Difference.Change] = [
            .remove(offset: (currentStack.endIndex - 1), element: poppedViewControllers[1], associatedWith: nil),
            .remove(offset: (currentStack.endIndex - 2), element: poppedViewControllers[0], associatedWith: nil)
        ]
        let expectedDifference = Stack.Difference.init(removals)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.changes, expectedDifference)
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
        let currentStack = sut.stack
        let targetViewController = StackViewController.knwownViewControllerB
        let poppedViewControllers = Array(currentStack.suffix(1))
        let removals: [Stack.Difference.Change] = [
            .remove(offset: (currentStack.endIndex - 1), element: poppedViewControllers[0], associatedWith: nil),
        ]
        let expectedDifference = Stack.Difference.init(removals)

        // Act
        sut.popTo(targetViewController, animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.changes, expectedDifference)
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

    // MARK: - setStack(_: Stack, animated: Bool)

    func testThat_whenReplacingCurrentStackWithSameStack_theStackIsNotChangedAndTheStackDidChangeMethodIsNotInvoked() {
        // Arrange
        let currentStack = sut.stack
        let sameStack = sut.stack

        // Act
        sut.setStack(sameStack, animated: true)

        // Assert
        XCTAssertFalse(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(sut.stack, currentStack)
    }

    func testThat_whenReplacingCurrentStackWithAStackContainingDuplicates_theStackIsNotChangedAndTheStackDidChangeMethodIsNotInvoked() {
        // Arrange
        let currentStack = sut.stack
        let duplicatesStack = [
            StackViewController.knwownViewControllerB,
            StackViewController.knwownViewControllerB,
            StackViewController.knwownViewControllerA,
            StackViewController.knwownViewControllerB
        ]

        // Act
        sut.setStack(duplicatesStack, animated: true)

        // Assert
        XCTAssertFalse(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(sut.stack, currentStack)
    }

    func testThat_ReplacingCurrentStackWithAValidStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheCollectionDifferenceAsInput() {
        // Arrange
        let validStackFirst = UIViewController()
        let validStackLast = UIViewController()
        let validStack = [
            validStackFirst,
            StackViewController.knwownViewControllerC,
            validStackLast
        ]

        let removals: [Stack.Difference.Change] = [
            .remove(offset: 1, element: StackViewController.knwownViewControllerB, associatedWith: nil),
            .remove(offset: 0, element: StackViewController.knwownViewControllerA, associatedWith: nil)
        ]
        let insertions: [Stack.Difference.Change] = [
            .insert(offset: 0, element: validStackFirst, associatedWith: nil),
            .insert(offset: 2, element: validStackLast, associatedWith: nil)
        ]
        let expectedDifference = Stack.Difference.init(removals
        + insertions)

        // Act
        sut.setStack(validStack, animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.changes, expectedDifference)
    }
}

fileprivate extension StackInteractorTests {

    enum Scenario {
        case pushNonDuplicate(UIViewController)
        case pushStackWithoutDuplicates(Stack)
        case popViewController
        case popToMiddleViewController(UIViewController)
        case popToRoot
        case replaceStackWithValidStack(Stack)
    }

    func expectedStack(after scenario: Scenario) -> Stack {
        switch scenario {
        case .pushNonDuplicate(let element): return initialStack + [element]
        case .pushStackWithoutDuplicates(let stack): return initialStack + stack
        case .popViewController: return initialStack.dropLast()
        case .popToMiddleViewController: return initialStack.dropLast()
        case .popToRoot: return initialStack.dropLast(2)
        case .replaceStackWithValidStack(let stack:) return stack
        @unknown default: assertionFailure()
        }
    }

    func expectedStackChanges(for scenario: Scenario) -> (inserts: Stack.Inserts, removals: Stack.Removals) {
        let difference = expectedStack(after: scenario).difference(from: initialStack)
        return (difference.insertions, difference.removals)
    }
}

extension StackInteractorDelegate {
    func didAddStackElements(_: Stack) {}
    func didRemoveStackElements(_: Stack) {}
    func didReplaceStack(_ oldStack: Stack, with newStack: Stack) {}

    func stackDidChange(_ change: Stack.Difference) {}
    func didCreateTransition(_: Transition) {}
}
