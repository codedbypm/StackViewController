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

    // MARK: - XCTestCase

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - push

    func testThat_whenStackHandlerCannotPushAViewController_itDoesNotCallPushViewController() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPushViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        XCTAssertNil(stackHandler.didCallPush)

        // Act
        sut.pushViewController(UIViewController(), animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPush)
    }

    func testThat_whenStackHandlerCannotPushAViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPushViewControllerFlag = false

        let sut = MockStackViewControllerInteractor(stackHandler: stackHandler)

        XCTAssertNil(sut.didCallPerformTransition)

        // Act
        sut.pushViewController(UIViewController(), animated: true)

        // Assert
        XCTAssertNil(sut.didCallPerformTransition)
    }

    func testThat_whenStackHandlerCannotPushAViewController_theSVCDoesNotSendViewControllerContainmentBeginEvents() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPushViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        let mockDelegate = MockStackViewControllerInteractorDelegate()
        sut.delegate = mockDelegate

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertNil(mockDelegate.didCallPrepareAddingChild)
        XCTAssertNil(mockDelegate.childAdded)
    }

    func testThat_whenStackHandlerCanPushAViewController_itCallsPushViewController() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPushViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        XCTAssertNil(stackHandler.didCallPush)

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPush, true)
    }

    func testThat_whenStackHandlerCanPushAViewController_theSVCSendsViewControllerContainmentBeginEvents() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPushViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        let mockDelegate = MockStackViewControllerInteractorDelegate()
        sut.delegate = mockDelegate

        XCTAssertNil(mockDelegate.didCallPrepareAddingChild)
        XCTAssertNil(mockDelegate.childAdded)

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertEqual(mockDelegate.didCallPrepareAddingChild, true)
        XCTAssertEqual(mockDelegate.childAdded, .last)
    }

    func testThat_whenStackHandlerCanPushAViewControllerAndSVCViewIsNotInHierarchy_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPushViewControllerFlag = true

        let sut = MockStackViewControllerInteractor(stackHandler: stackHandler)

        XCTAssertNil(sut.didCallPerformTransition)

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertNil(sut.didCallPerformTransition)
    }

    // MARK: - popViewController

    func testThat_whenStackHandlerCannotPopAViewController_itDoesNotCallPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPopViewControllerFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopViewController)
    }

    func testThat_whenStackHandlerCannotPopAViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
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
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPopViewControllerFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPopViewController, true)
    }

    // MARK: - popToRoot

    func testThat_whenStackHandlerCannotPopToRoot_itDoesNotCallPopViewController() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPopToRootFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopViewController)
    }

    func testThat_whenStackHandlerCannotPopToRoot_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
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
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPopToRootFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPopToRoot, true)
    }

    // MARK: - popTo

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCallPopToViewController() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPopToFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallPopToViewController)
    }

    func testThat_whenStackHandlerCannotPopToViewController_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
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
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canPopToFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.pop(to: UIViewController(), animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallPopToViewController, true)
    }

    // MARK: - setStack

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCallSetStack() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canSetStackFlag = false

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertNil(stackHandler.didCallSetStack)
    }

    func testThat_whenStackHandlerCannotSetStack_itDoesNotCallPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
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
        let stackHandler = MockStackHandler(stack: [])
        stackHandler.canSetStackFlag = true

        sut = StackViewControllerInteractor(stackHandler: stackHandler)

        // Act
        sut.setStack([.last], animated: true)

        // Assert
        XCTAssertEqual(stackHandler.didCallSetStack, true)
    }
}


/// This tests are grouped in an extension because the all need a different mock of StackViewControllerInteractor.
/// One that only mocks the `performTransition` method, since that is the one being tested. 
extension StackViewControllerInteractorTests {

    class MockSut: StackViewControllerInteractor {
        var context: TransitionContext?
        var didCallPerformTransition: Bool?
        override func performTransition(context: TransitionContext) {
            didCallPerformTransition = true
            self.context = context
        }
    }

    func testThat_whenStackHandlerCanPushAViewControllerAndSVCViewIsInHierarchy_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first])
        stackHandler.canPushViewControllerFlag = true

        let sut = MockSut(stackHandler: stackHandler)

        let delegate = StackViewController.embeddedInWindow()
        sut.delegate = delegate

        // Act
        sut.pushViewController(.last, animated: true)

        // Assert
        XCTAssertEqual(sut.didCallPerformTransition, true)
        XCTAssertEqual(sut.context?.operation, StackViewController.Operation.push)
        XCTAssertEqual(sut.context?.from, .first)
        XCTAssertEqual(sut.context?.to, .last)
        XCTAssertEqual(sut.context?.isAnimated, true)
        XCTAssertEqual(sut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.context?.isInteractive, false)

    }

    func testThat_whenStackHandlerCanPopAViewController_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first, .middle])
        stackHandler.canPopViewControllerFlag = true

        let sut = MockSut(stackHandler: stackHandler)

        // Act
        sut.popViewController(animated: true)

        // Assert
        XCTAssertEqual(sut.didCallPerformTransition, true)
        XCTAssertEqual(sut.context?.operation, .pop)
        XCTAssertEqual(sut.context?.from, .middle)
        XCTAssertEqual(sut.context?.to, .first)
        XCTAssertEqual(sut.context?.isAnimated, true)
        XCTAssertEqual(sut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.context?.isInteractive, false)
    }

    func testThat_whenStackHandlerCanPopToRoot_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [.first, .middle])
        stackHandler.canPopToRootFlag = true

        let sut = MockSut(stackHandler: stackHandler)

        // Act
        sut.popToRoot(animated: true)

        // Assert
        XCTAssertEqual(sut.didCallPerformTransition, true)
        XCTAssertEqual(sut.context?.operation, .pop)
        XCTAssertEqual(sut.context?.from, .middle)
        XCTAssertEqual(sut.context?.to, .first)
        XCTAssertEqual(sut.context?.isAnimated, true)
        XCTAssertEqual(sut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.context?.isInteractive, false)
    }

    func testThat_whenStackHandlerCanPopToViewController_itCallsPerformTransition() {
        // Arrange
        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canPopToFlag = true

        let sut = MockSut(stackHandler: stackHandler)

        // Act
        sut.pop(to: .middle, animated: true)

        // Assert
        XCTAssertEqual(sut.didCallPerformTransition, true)
        XCTAssertEqual(sut.context?.operation, .pop)
        XCTAssertEqual(sut.context?.from, .last)
        XCTAssertEqual(sut.context?.to, .middle)
        XCTAssertEqual(sut.context?.isAnimated, true)
        XCTAssertEqual(sut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.context?.isInteractive, false)
    }

    func testThat_whenStackHandlerCanSetStackAndViewIsInHierarchy_itCallsPerformTransition() {
        // Arrange
        let stackOperationProvider = MockStackOperationProvider()
        stackOperationProvider.stackOperationValue = .pop

        let stackHandler = MockStackHandler(stack: .default)
        stackHandler.canSetStackFlag = true

        let sut = MockSut(stackHandler: stackHandler,
                          stackOperationProvider: stackOperationProvider)

        let delegate = StackViewController.embeddedInWindow()
        sut.delegate = delegate

        // Act
        sut.setStack([.first], animated: true)

        // Assert
        XCTAssertEqual(sut.didCallPerformTransition, true)
        XCTAssertEqual(sut.context?.operation, .pop)
        XCTAssertEqual(sut.context?.from, .last)
        XCTAssertEqual(sut.context?.to, .first)
        XCTAssertEqual(sut.context?.isAnimated, true)
        XCTAssertEqual(sut.context?.containerView,
                       sut.viewControllerWrapperView)
        XCTAssertEqual(sut.context?.isInteractive, false)
    }
}
