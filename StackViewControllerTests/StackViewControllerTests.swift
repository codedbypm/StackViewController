//
//  StackViewControllerTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
import UIKit

@testable import StackViewController

class StackViewControllerTests: XCTestCase {
    var sut: StackViewController!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - pushViewController(_: animated:)

    func testThat_whenPushingViewControllerWhichIsAlreadyOnTheStack_theViewControllerIsNotPushed() {
        // Arrange
        let testViewController = UIViewController()
        sut = StackViewController(viewControllers: [testViewController])

        // Act
        sut.pushViewController(testViewController, animated: true)

        // Assert
        XCTAssertEqual(sut.viewControllers, [testViewController])
    }



}
