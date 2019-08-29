//
//  MockStackViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 28/08/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

@testable import StackViewController

class MockStackViewController: StackViewController {

    var controllers: [UIViewController]?
    var viewControllersGetterDates: [Date] = []
    var viewControllersSetterDates: [Date] = []
    override var viewControllers: [UIViewController] {
        get {
            viewControllersGetterDates.append(Date())
            return controllers ?? []
        }
        set {
            viewControllersSetterDates.append(Date())
            super.viewControllers = newValue
        }
    }

    var viewCycleEventDates: [Date] {
        return
            viewDidLoadDates
            + viewWillAppearDates
            + viewDidAppearDates
    }

    var stackOperationDates: [Date] {
        return
            pushViewControllerDates
            + viewControllersGetterDates
            + viewControllersSetterDates
            + popToRootDates
            + setStackDates
    }

    var receivedEventDates: [Date] {
        return (viewCycleEventDates + stackOperationDates).sorted()
    }

    var isViewLoadedFlag = false
    override var isViewLoaded: Bool {
        return isViewLoadedFlag
    }

    var viewDidLoadDates: [Date] = []
    override func viewDidLoad() {
        viewDidLoadDates.append(Date())
        super.viewDidLoad()
    }

    var viewWillAppearDates: [Date] = []
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearDates.append(Date())
    }

    var viewDidAppearDates: [Date] = []
    override func viewDidAppear(_ animated: Bool) {
        viewDidAppearDates.append(Date())
    }

    var pushViewControllerDates: [Date] = []
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerDates.append(Date())
        super.pushViewController(viewController, animated: animated)
    }

    var popToRootDates: [Date] = []
    override func popToRootViewController(animated: Bool) -> Stack? {
        popToRootDates.append(Date())
        return super.popToRootViewController(animated: animated)
    }
    
    var setStackDates: [Date] = []
    override func setStack(_ stack: Stack, animated: Bool) {
        setStackDates.append(Date())
        super.setStack(stack, animated: animated)
    }
}

