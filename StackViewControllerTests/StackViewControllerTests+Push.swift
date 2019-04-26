//
//  StackViewControllerTests+Push.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - pushViewController(_: animated:)

    func testThat_whenPushingViewControllerWhichIsAlreadyOnTheStack_theViewControllerIsNotAddedToTheStack() {
        // Arrange
        sut = StackViewController.withKnownStack()
        let pushedViewController = StackViewController.knwownViewControllerB

        // Act
        sut.pushViewController(pushedViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.viewControllers, StackViewController.knownStack)
    }

    func testThat_whenPushingViewControllerAndTheCurrentStackIsEmpty_thePushedControllerIsImmediatelyAddedToTheStack() {
        // Arrange
        sut = StackViewController.withEmptyStack()
        let pushedViewController = StackViewController.knwownViewControllerB

        XCTAssertTrue(sut.viewControllers.isEmpty)

        // Act
        sut.pushViewController(pushedViewController, animated: true)

        // Assert
        XCTAssertEqual(pushedViewController.view.superview, sut.view)
        XCTAssertEqual(pushedViewController.parent, sut)
        XCTAssertEqual(sut.viewControllers, [pushedViewController])

    }

}
