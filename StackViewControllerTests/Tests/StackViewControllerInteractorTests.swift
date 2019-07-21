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

    private class MockSut: StackViewControllerInteractor {
        var didCallPerformTransition: Bool?
        var context: TransitionContext?
        override func performTransition(context: TransitionContext) {
            didCallPerformTransition = true
            self.context = context
        }
    }

    // MARK: - XCTestCase

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

    // MARK: - push

    func testThat_whenStackHandlerCannotPushAViewController_itDoesNotCallPushViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPushViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pushViewController(UIViewController(), animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPush)
    }

    func testThat_whenStackHandlerCannotPushAViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPushViewControllerFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler
        )

        // Act
        sut.pushViewController(UIViewController(), animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPushAViewController_itCallsPushViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPushViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPush, true)
    }

    func testThat_whenStackHandlerCanPushAViewController_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first])
        stackHandler.canPushViewControllerFlag = true

        let mockSut = MockSut(stackHandler: stackHandler)
        sut = mockSut

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertEqual(mockSut.didCallPerformTransition, true)
        XCTAssertTrue(mockSut === sut)
        XCTAssertEqual(mockSut.context?.operation, .push)
        XCTAssertEqual(mockSut.context?.from, .first)
        XCTAssertEqual(mockSut.context?.to, .last)
        XCTAssertEqual(mockSut.context?.isAnimated, true)
        XCTAssertEqual(mockSut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(mockSut.context?.isInteractive, false)

    }

    // MARK: - popViewController

    func testThat_whenStackHandlerCannotPopAViewController_itDoesNotCallPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopViewController)
    }

    func testThat_whenStackHandlerCannotPopAViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopViewControllerFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler
        )

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPopAViewController_itCallsPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPopViewController, true)
    }

    func testThat_whenStackHandlerCanPopAViewController_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first, .middle])
        stackHandler.canPopViewControllerFlag = true

        let mockSut = MockSut(stackHandler: stackHandler)
        sut = mockSut

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertEqual(mockSut.didCallPerformTransition, true)
        XCTAssertTrue(mockSut === sut)
        XCTAssertEqual(mockSut.context?.operation, .pop)
        XCTAssertEqual(mockSut.context?.from, .middle)
        XCTAssertEqual(mockSut.context?.to, .first)
        XCTAssertEqual(mockSut.context?.isAnimated, true)
        XCTAssertEqual(mockSut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(mockSut.context?.isInteractive, false)

    }

    // MARK: - popToRoot

    func testThat_whenStackHandlerCannotPopToRoot_itDoesNotCallPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToRootFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopViewController)
    }

    func testThat_whenStackHandlerCannotPopToRoot_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToRootFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler
        )

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPopToRoot_itCallsPopToRoot() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToRootFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPopToRoot, true)
    }

    func testThat_whenStackHandlerCanPopToRoot_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first, .middle])
        stackHandler.canPopToRootFlag = true

        let mockSut = MockSut(stackHandler: stackHandler)
        sut = mockSut

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(mockSut.didCallPerformTransition, true)
        XCTAssertTrue(mockSut === sut)
        XCTAssertEqual(mockSut.context?.operation, .pop)
        XCTAssertEqual(mockSut.context?.from, .middle)
        XCTAssertEqual(mockSut.context?.to, .first)
        XCTAssertEqual(mockSut.context?.isAnimated, true)
        XCTAssertEqual(mockSut.context?.containerView,
                       mockSut.viewControllerWrapperView)
        XCTAssertEqual(mockSut.context?.isInteractive, false)

    }

    // MARK: - popTo

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCallPopToViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopToViewController)
    }

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler
        )

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPopToViewController_itCallsPopToViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPopToViewController, true)
    }

    func testThat_whenStackHandlerCanPopToViewController_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canPopToFlag = true

        let mockSut = MockSut(stackHandler: stackHandler)
        sut = mockSut

        // Act
        sut.pop(to: .middle, animated: true)

        // Assert
        XCTAssertEqual(mockSut.didCallPerformTransition, true)
        XCTAssertTrue(mockSut === sut)
        XCTAssertEqual(mockSut.context?.operation, .pop)
        XCTAssertEqual(mockSut.context?.from, .last)
        XCTAssertEqual(mockSut.context?.to, .middle)
        XCTAssertEqual(mockSut.context?.isAnimated, true)
        XCTAssertEqual(mockSut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(mockSut.context?.isInteractive, false)
    }

    // MARK: - setStack

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCallSetStack() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallSetStack)
    }

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler
        )

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanSetStack_itCallsSetStack() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallSetStack, true)
    }

    func testThat_whenStackHandlerCanSetStack_itCallsPerformTransition() {
        // Arrange
        let stackOperationProvider = MockStackOperationProvider()
        stackOperationProvider.stackOperationValue = .pop

        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canSetStackFlag = true

        let mockSut = MockSut(stackHandler: stackHandler,
                              stackOperationProvider: stackOperationProvider)
        sut = mockSut

        // Act
        sut.setStack([.first], animated: true)

        // Assert
        XCTAssertEqual(mockSut.didCallPerformTransition, true)
        XCTAssertTrue(mockSut === sut)
        XCTAssertEqual(mockSut.context?.operation, .pop)
        XCTAssertEqual(mockSut.context?.from, .last)
        XCTAssertEqual(mockSut.context?.to, .first)
        XCTAssertEqual(mockSut.context?.isAnimated, true)
        XCTAssertEqual(mockSut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(mockSut.context?.isInteractive, false)
    }
}
