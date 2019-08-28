//
//  MockStackHandler.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 09/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackHandler: StackHandling {

    var stack: Stack

    init(stack: Stack) {
        self.stack = stack
    }

    // MARK: - pushViewController

    var canPushViewControllerFlag = false
    func canPushViewController(_: UIViewController) -> Bool {
        return canPushViewControllerFlag
    }

    var didCallPush: Bool?
    var pushedViewController: UIViewController?
    func pushViewController(_ viewController: UIViewController) {
        didCallPush = true
        pushedViewController = viewController
    }

    // MARK: - pop

    var canPopViewControllerFlag = false
    func canPopViewController() -> Bool {
        return canPopViewControllerFlag
    }

    var didCallPopViewController: Bool?
    var poppedViewController = UIViewController()
    func popViewController() -> UIViewController? {
        didCallPopViewController = true
        return poppedViewController
    }

    // MARK: - popToRoot

    var canPopToRootFlag = false
    func canPopToRoot() -> Bool {
        return canPopToRootFlag
    }

    var didCallPopToRoot: Bool?
    var poppedToRootViewControllers: [UIViewController] = []
    func popToRoot() -> [UIViewController]? {
        didCallPopToRoot = true
        return poppedToRootViewControllers
    }

    // MARK: - pop(to:)

    var canPopToFlag = false
    func canPop(to: UIViewController) -> Bool {
        return canPopToFlag
    }

    var didCallPopToViewController: Bool?
    var poppedViewControllers: [UIViewController] = []
    func pop(to viewController: UIViewController) -> [UIViewController]? {
        didCallPopToViewController = true
        return poppedViewControllers
    }

    // MARK: - setStack(:)

    var canSetStackFlag = false
    func canSetStack(_: Stack) -> Bool {
        return canSetStackFlag
    }

    var didCallSetStack: Bool?
    var newStack: Stack = []
    func setStack(_ newStack: Stack) {
        didCallSetStack = true
        self.newStack = newStack
    }
}
