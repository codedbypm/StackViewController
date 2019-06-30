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

    // MARK: - performTransition(:)

    func testThat_whenPerformingTransition_itCallsDelegateWillStartTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        // Act
        sut.performTransition(.dummy)

        // Assert
        XCTAssertEqual(delegate.didCallWillStartTransition, true)
    }

    // MARK: - performTransition(animationController:)

    func testThat_whenPerformingAnimatedTransitionWithAContext_itCallsDelegateWillStartTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        
        // Act
        sut.performAnimatedTransition(
            context: .dummy,
            animationController: MockAnimatedTransitioning()
        )

        // Assert
        XCTAssertEqual(delegate.didCallWillStartTransition, true)
    }

    func testThat_whenPerformingAnimatedTransitionWithAContext_itCallsAnimateTransition() {
        // Arrange
        let delegate = MockTransitionHandlerDelegate()
        sut.delegate = delegate

        let animationController = MockAnimatedTransitioning()

        // Act
        sut.performAnimatedTransition(
            context: .dummy,
            animationController: animationController
        )

        // Assert
        XCTAssertEqual(animationController.didCallAnimateTransition, true)
    }
}
