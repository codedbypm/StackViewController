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

    func testThat_whenPerformingAnimatedTransition_itCallsDelegateWillStartTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        
        // Act
        sut.performTransition(
            context: .dummy,
            animationController: MockAnimatedTransitioning(),
            interactionController: nil
        )

        // Assert
        XCTAssertEqual(delegate.didCallWillStartTransition, true)
    }

    func testThat_whenPerformingAnimatedTransition_itCallsAnimateTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        let animationController = MockAnimatedTransitioning()

        // Act
        sut.performTransition(
            context: .dummy,
            animationController: animationController,
            interactionController: nil
        )

        // Assert
        XCTAssertEqual(animationController.didCallAnimateTransition, true)
    }
}
