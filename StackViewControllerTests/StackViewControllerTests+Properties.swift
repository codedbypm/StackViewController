//
//  StackViewControllerTests+Properties.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - topViewController

    func testThat_whenTheStackIsEmpty_topViewControllerIsNil() {
        // Arrange
        sut = StackViewController.withEmptyStack()

        // Act
        let topViewController = sut.topViewController

        // Assert
        XCTAssertNil(topViewController)
    }

    func testThat_whenTheStackIsNotEmpty_topViewControllerEqualsTheLastElementOfTheStack() {
        // Arrange
        sut = StackViewController.withNumberOfViewControllers(3)

        // Act
        let topViewController = sut.topViewController

        // Assert
        XCTAssertNotNil(topViewController)
        XCTAssertEqual(topViewController, sut.stack.last)
    }

    // MARK: - visibleViewController

    func testThat_whenTheStackIsEmpty_visibleViewControllerIsNil() {
        // Arrange
        sut = StackViewController.withEmptyStack()

        // Act
        let visibleViewController = sut.visibleViewController

        // Assert
        XCTAssertNil(visibleViewController)
    }

    func testThat_whenTopViewControllerViewIsNotLoaded_visibleViewControllerIsNil() {
        // Arrange
        sut = StackViewController.withNumberOfViewControllers(3)
        guard let topViewController = sut.topViewController, !topViewController.isViewLoaded else {
            XCTFail("topViewController's view should not be loaded")
            return
        }

        // Act
        let visibleViewController = sut.visibleViewController

        // Assert
        XCTAssertNil(visibleViewController)
    }

    func testThat_whenTopViewControllerViewIsLoadedButNotAddedToTheViewHierarchy_visibleViewControllerIsNil() {
        // Arrange
        sut = StackViewController
            .withNumberOfViewControllers(3)
            .loadingTopViewControllerView()

        guard let topViewController = sut.topViewController, topViewController.isViewLoaded else {
            XCTFail("topViewController's view should be loaded")
            return
        }

        XCTAssertNil(topViewController.view.superview)

        // Act
        let visibleViewController = sut.visibleViewController

        // Assert
        XCTAssertNil(visibleViewController)
    }

    func testThat_whenTopViewControllerViewIsAddedToTheStackViewControllerView_visibleViewControllerIsNotNil() {
        // Arrange
        sut = StackViewController
            .withNumberOfViewControllers(3)
            .showingTopViewControllerView()

        guard let topViewController = sut.topViewController, topViewController.view.superview != nil else {
            XCTFail("topViewController's view should have a superview")
            return
        }

        // Act
        let visibleViewController = sut.visibleViewController

        // Assert
        XCTAssertNotNil(visibleViewController)
        XCTAssertEqual(visibleViewController, topViewController)
    }
}
