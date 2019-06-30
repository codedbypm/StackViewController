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
}
