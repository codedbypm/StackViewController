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
    var initialStack = Stack.default

    override func setUp() {
        interactorDelegate = InteractorDelegate()

        sut = StackInteractor(stack: initialStack)
        sut.delegate = interactorDelegate
    }

    override func tearDown() {
        sut = nil
        interactorDelegate = nil
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
        let pushedViewController = UIViewController()

        // Act
        sut.push(pushedViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, initialStack + [pushedViewController])
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
        let pushedViewController = Stack.firstViewController

        // Act
        sut.push(pushedViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, initialStack)
    }

    // MARK: - push(_: Stack, animated: Bool)

    func testThat_whenPushingAValidStack_thisIsAppendedToTheCurrentStack() {
        // Arrange
        let pushedStack = [UIViewController()]

        // Act
        sut.push(pushedStack, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, initialStack + pushedStack)
    }

    func testThat_whenPushingAValidStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let pushedStack = Stack.any(ofSize: 3)
        let testScenario: Scenario = .pushStackWithoutDuplicates(pushedStack)
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.push(pushedStack, animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.inserts, expectedStackChanges.inserts)
        XCTAssertEqual(interactorDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenPushingAStackResultingInANewStackWithDuplicates_theCurrentStackIsNotChanged() {
        // Arrange
        let pushedStack = [Stack.firstViewController]

        // Act
        sut.push(pushedStack, animated: true)

        // Assert
        XCTAssertEqual(sut.stack, initialStack)
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

    func testThat_whenPoppingAViewController_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let testScenario: Scenario = .popViewController
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.pop(animated: true)

        // Assert

        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.inserts, expectedStackChanges.inserts)
        XCTAssertEqual(interactorDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenTheStackContainsOnlyOneElement_whenPoppingAViewController_theCurrentStackIsNotChangedAndTheMethodReturnsNil() {
        // Arrange
        let oneElementStack = [Stack.firstViewController]
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

        // Act
        let poppedViewControllers = sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(poppedViewControllers, Array(initialStack.dropFirst()))
        XCTAssertEqual(sut.stack, [initialStack.first])
    }

    func testThat_whenPoppingToRoot_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let testScenario: Scenario = .popToRoot
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.inserts, expectedStackChanges.inserts)
        XCTAssertEqual(interactorDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenTheStackContainsOnlyOneElement_whenPoppingToRoot_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let oneElementStack = [Stack.firstViewController]
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
        let targetViewController = Stack.middleViewController

        // Act
        let poppedViewControllers = sut.popTo(targetViewController, animated: true)

        // Assert
        XCTAssertEqual(poppedViewControllers, Array(initialStack.dropFirst(2)))
        XCTAssertEqual(sut.stack, initialStack.dropLast())
    }

    func testThat_whenPoppingToAViewControllerAlreadyOnTheStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let testScenario: Scenario = .popToViewControllerAlreadyOnStack
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.popTo(Stack.middleViewController, animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.inserts, expectedStackChanges.inserts)
        XCTAssertEqual(interactorDelegate.removals, expectedStackChanges.removals)
    }

    func testThat_whenPoppingToAViewControllerWhichIsNotOnTheStack_theCurrentStackIsNotChangedAndTheMethodReturnsEmptyArray() {
        // Arrange
        let targetViewController = UIViewController()

        // Act
        let poppedViewControllers = sut.popTo(targetViewController, animated: true)

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
        sut.setStack(sameStack, animated: true)

        // Assert
        XCTAssertFalse(interactorDelegate.didCallStackDidChange)
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
        sut.setStack(duplicatesStack, animated: true)

        // Assert
        XCTAssertFalse(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(sut.stack, initialStack)
    }

    func testThat_ReplacingCurrentStackWithAValidStack_theStackDidChangeMethodIsInvokedOnTheDelegateWithTheInsertsAndRemovalsAsInput() {
        // Arrange
        let newStack = Stack.any(ofSize: 5)
        let testScenario: Scenario = .replaceStackWithValidStack(newStack)
        let expectedStackChanges = self.expectedStackChanges(for: testScenario)

        // Act
        sut.setStack(newStack, animated: true)

        // Assert
        XCTAssertTrue(interactorDelegate.didCallStackDidChange)
        XCTAssertEqual(interactorDelegate.inserts, expectedStackChanges.inserts)
        XCTAssertEqual(interactorDelegate.removals, expectedStackChanges.removals)
    }
}

fileprivate extension StackInteractorTests {

    enum Scenario {
        case pushNonDuplicate(UIViewController)
        case pushStackWithoutDuplicates(Stack)
        case popViewController
        case popToViewControllerAlreadyOnStack
        case popToRoot
        case replaceStackWithValidStack(Stack)
    }

    func expectedStack(after scenario: Scenario) -> Stack {
        switch scenario {
        case .pushNonDuplicate(let element): return initialStack + [element]
        case .pushStackWithoutDuplicates(let stack): return initialStack + stack
        case .popViewController: return initialStack.dropLast()
        case .popToViewControllerAlreadyOnStack: return initialStack.dropLast()
        case .popToRoot: return initialStack.dropLast(2)
        case .replaceStackWithValidStack(let stack): return stack
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
