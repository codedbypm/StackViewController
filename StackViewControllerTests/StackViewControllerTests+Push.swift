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
        let testViewController = UIViewController()
        sut = StackViewController(viewControllers: [testViewController])

        // Act
        sut.pushViewController(testViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.viewControllers, [testViewController])
    }
}
