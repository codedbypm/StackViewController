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

    func testThat_whenStackHandlerCannotPushAViewController_itDoesNotCreateATransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPushViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pushViewController(UIViewController(), animated: true)

        // Assert
        XCTAssertNil(sut.transitionContext)
    }

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
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.pushViewController(UIViewController(), animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPushAViewController_itConfiguresTransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first])
        stackHandler.canPushViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, .push)
        XCTAssertEqual(sut.transitionContext?.from, .first)
        XCTAssertEqual(sut.transitionContext?.to, .last)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
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
        let stackHandler = MockStackHandler()
        stackHandler.canPushViewControllerFlag = true
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertEqual(transitionHandler.didCallPerformTransition, true)
    }

    // MARK: - popViewController

    func testThat_whenStackHandlerCannotPopAViewController_itDoesNotCreateATransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertNil(sut.transitionContext)
    }

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
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPopAViewController_itConfiguresTransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first, .middle])
        stackHandler.canPopViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, .pop)
        XCTAssertEqual(sut.transitionContext?.from, .middle)
        XCTAssertEqual(sut.transitionContext?.to, .first)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
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
        let stackHandler = MockStackHandler()
        stackHandler.canPopViewControllerFlag = true
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertEqual(transitionHandler.didCallPerformTransition, true)
    }

    // MARK: - popToRoot

    func testThat_whenStackHandlerCannotPopToRoot_itDoesNotCreateATransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToRootFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertNil(sut.transitionContext)
    }

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
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPopToRoot_itConfiguresTransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first, .middle])
        stackHandler.canPopToRootFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, .pop)
        XCTAssertEqual(sut.transitionContext?.from, .middle)
        XCTAssertEqual(sut.transitionContext?.to, .first)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
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
        let stackHandler = MockStackHandler()
        stackHandler.canPopToRootFlag = true
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(transitionHandler.didCallPerformTransition, true)
    }

    // MARK: - popTo

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCreateATransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertNil(sut.transitionContext)
    }

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCallPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopViewController)
    }

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCanPopToViewController_itConfiguresTransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canPopToFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: .middle, animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, .pop)
        XCTAssertEqual(sut.transitionContext?.from, .last)
        XCTAssertEqual(sut.transitionContext?.to, .middle)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
    }

    func testThat_whenStackHandlerCanPopToViewController_itCallsPopToRoot() {
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
        let stackHandler = MockStackHandler()
        stackHandler.canPopToFlag = true
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertEqual(transitionHandler.didCallPerformTransition, true)
    }

    // MARK: - setStack

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCreateATransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNil(sut.transitionContext)
    }

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCallPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopViewController)
    }

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = false
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNil(transitionHandler.didCallPerformTransition)
    }

    func testThat_whenSettingStackWouldResultInAPushOperation_itConfiguresTransitionContext() {
        // Arrange
        let viewController = UIViewController()
        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canSetStackFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([viewController], animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, .push)
        XCTAssertEqual(sut.transitionContext?.from, .last)
        XCTAssertEqual(sut.transitionContext?.to, viewController)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
    }

    func testThat_whenSettingStackWouldResultInAPopOperation_itConfiguresTransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canSetStackFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.first], animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, .pop)
        XCTAssertEqual(sut.transitionContext?.from, .last)
        XCTAssertEqual(sut.transitionContext?.to, .first)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
    }

    func testThat_whenSettingStackWouldResultInNoOperation_itConfiguresTransitionContext() {
        // Arrange
        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canSetStackFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNotNil(sut.transitionContext)
        XCTAssertEqual(sut.transitionContext?.operation, StackViewController.Operation.none)
        XCTAssertEqual(sut.transitionContext?.from, .last)
        XCTAssertEqual(sut.transitionContext?.to, .last)
        XCTAssertEqual(sut.transitionContext?.isAnimated, true)
        XCTAssertEqual(sut.transitionContext?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.transitionContext?.isInteractive, false)
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
        let stackHandler = MockStackHandler()
        stackHandler.canSetStackFlag = true
        let transitionHandler = MockTransitionHandler()

        sut = StackViewControllerInteractor(
            stackHandler: stackHandler,
            transitionHandler: transitionHandler
        )

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertEqual(transitionHandler.didCallPerformTransition, true)
    }
}

