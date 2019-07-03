//
//  TransitionHandlerTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 30/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class TransitionHandlerTests: XCTestCase {
    var sut: TransitionHandler!

    override func setUp() {
        super.setUp()
        sut = TransitionHandler()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - performTransition(context:animationController:)

    func testThat_whenPerformingTransition_itCallsDelegateWillStartTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        // Act
        sut.performTransition(
            context: .dummyAnimated,
            animationController: MockAnimatedTransitioning()
        )

        // Assert
        XCTAssertEqual(delegate.didCallWillStartTransition, true)
    }

    func testThat_whenPerformingTransition_itCallsAnimateTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        let animationController = MockAnimatedTransitioning()

        // Act
        sut.performTransition(
            context: .dummyAnimated,
            animationController: animationController
        )

        // Assert
        XCTAssertEqual(animationController.didCallAnimateTransition, true)
    }

    // MARK: - performTransition(context:interactionController:)

    func testThat_whenPerformingInteractiveTransition_itCallsDelegateWillStartTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        // Act
        sut.performInteractiveTransition(
            context: .dummyAnimated,
            interactionController: MockInteractiveTransitioning()
        )

        // Assert
        XCTAssertEqual(delegate.didCallWillStartTransition, true)
    }

    func testThat_whenPerformingInteractiveTransition_itCallsStartInteractiveTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        let interactionController = MockInteractiveTransitioning()

        // Act
        sut.performInteractiveTransition(
            context: .dummyAnimated,
            interactionController: interactionController
        )

        // Assert
        XCTAssertEqual(interactionController.didCallStartInteractiveTransition, true)
    }


}
