//
//  StackViewControllerTests+ViewEvents.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 15/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - viewWillAppear

    func testThat_whenViewWillAppear_itCallsInteractorViewWillAppear() {
        // Arrange
        let animated = false
        let interactor = MockStackViewControllerInteractor()
        sut = StackViewController(interactor: interactor)

        XCTAssertNil(interactor.didCallViewWillAppear)
        XCTAssertNil(interactor.isAnimated)

        // Act
        sut.viewWillAppear(animated)

        // Assert
        XCTAssertEqual(interactor.didCallViewWillAppear, true)
        XCTAssertEqual(interactor.isAnimated, animated)
    }

    // MARK: - viewDidAppear

    func testThat_whenViewDidAppear_itCallsInteractorViewDidAppear() {
        // Arrange
        let animated = false
        let interactor = MockStackViewControllerInteractor()
        sut = StackViewController(interactor: interactor)

        XCTAssertNil(interactor.didCallViewDidAppear)
        XCTAssertNil(interactor.isAnimated)

        // Act
        sut.viewDidAppear(animated)

        // Assert
        XCTAssertEqual(interactor.didCallViewDidAppear, true)
        XCTAssertEqual(interactor.isAnimated, animated)
    }

    // MARK: - viewWillDisappear

    func testThat_whenViewWillDisappear_itCallsInteractorViewWillDisappear() {
        // Arrange
        let animated = false
        let interactor = MockStackViewControllerInteractor()
        sut = StackViewController(interactor: interactor)

        XCTAssertNil(interactor.didCallViewWillDisappear)
        XCTAssertNil(interactor.isAnimated)

        // Act
        sut.viewWillDisappear(animated)

        // Assert
        XCTAssertEqual(interactor.didCallViewWillDisappear, true)
        XCTAssertEqual(interactor.isAnimated, animated)
    }

    // MARK: - viewDidDisappear

    func testThat_whenViewDidDisappear_itCallsInteractorViewDidDisappear() {
        // Arrange
        let animated = false
        let interactor = MockStackViewControllerInteractor()
        sut = StackViewController(interactor: interactor)

        XCTAssertNil(interactor.didCallViewDidDisappear)
        XCTAssertNil(interactor.isAnimated)

        // Act
        sut.viewDidDisappear(animated)

        // Assert
        XCTAssertEqual(interactor.didCallViewDidDisappear, true)
        XCTAssertEqual(interactor.isAnimated, animated)
    }
}
