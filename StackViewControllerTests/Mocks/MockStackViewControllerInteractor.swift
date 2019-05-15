//
//  MockStackViewControllerInteractor.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 14/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackViewControllerInteractor: StackViewControllerInteractor {

    var didCallStackGetter: Bool?
    override var stack: Stack {
        didCallStackGetter = true
        return Stack.default
    }

    var didCallPushViewControllerAnimated: Bool?
    var pushedViewController: UIViewController?
    var pushedViewControllerAnimated: Bool?
    override func push(_ viewController: UIViewController, animated: Bool) {
        didCallPushViewControllerAnimated = true
        pushedViewController = viewController
        pushedViewControllerAnimated = animated
    }

    var didCallPushStackAnimated: Bool?
    var pushedStack: Stack?
    var pushedStackAnimated: Bool?
    override func push(_ stack: Stack, animated: Bool) {
        didCallPushStackAnimated = true
        pushedStack = stack
        pushedStackAnimated = animated
    }

    var didCallPopAnimatedInteractive: Bool?
    var popAnimated: Bool?
    var popInteractive: Bool?
    var popReturnValue: UIViewController?
    override func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        didCallPopAnimatedInteractive = true
        popAnimated = animated
        popInteractive = interactive
        return popReturnValue
    }

    var didCallPopToRootAnimated: Bool?
    var popToRootAnimated: Bool?
    var popToRootReturnValue: Stack = []
    override func popToRoot(animated: Bool) -> Stack {
        didCallPopToRootAnimated = true
        popToRootAnimated = animated
        return popToRootReturnValue
    }

    var didCallPopToViewControllerAnimated: Bool?
    var popToViewControllerViewController: UIViewController?
    var popToViewControllerAnimated: Bool?
    var popToViewControllerReturnValue: Stack = []
    override func popTo(_ viewController: UIViewController, animated: Bool) -> Stack {
        didCallPopToViewControllerAnimated = true
        popToViewControllerViewController = viewController
        popToViewControllerAnimated = animated
        return popToViewControllerReturnValue
    }
    
    var didCallSetStackAnimated: Bool?
    var setStackStack: Stack?
    var setStackAnimated: Bool?
    override func setStack(_ newStack: Stack, animated: Bool) {
        didCallSetStackAnimated = true
        setStackStack = newStack
        setStackAnimated = animated
    }
}
