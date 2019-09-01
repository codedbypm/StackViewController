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
    var stackGetterDates: [Date] = []
    var stackSetterDates: [Date] = []
    override var stack: [UIViewController] {
        get {
            stackGetterDates.append(Date())
            return controllers ?? []
        }
        set {
            stackSetterDates.append(Date())
            super.stack = newValue
        }
    }

    var viewCycleEventDates: [Date] {
        return
            viewDidLoadDates
            + viewWillAppearDates
            + viewDidAppearDates
            + viewWillDisappearDates
            + viewDidDisappearDates
    }

    var stackOperationDates: [Date] {
        return
            pushViewControllerDates
            + stackGetterDates
            + stackSetterDates
            + popToRootDates
            + setStackDates
    }

    var receivedEventDates: [Date] {
        return (viewCycleEventDates + stackOperationDates).sorted()
    }

    var viewDidLoadDates: [Date] = []
    override func viewDidLoad() {
        viewDidLoadDates.append(Date())
        super.viewDidLoad()
    }

    var viewWillAppearDates: [Date] = []
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearDates.append(Date())
        super.viewWillAppear(animated)
    }

    var viewDidAppearDates: [Date] = []
    override func viewDidAppear(_ animated: Bool) {
        viewDidAppearDates.append(Date())
        super.viewDidAppear(animated)
    }

    var viewWillDisappearDates: [Date] = []
    override func viewWillDisappear(_ animated: Bool) {
        viewWillDisappearDates.append(Date())
        super.viewWillDisappear(animated)
    }

    var viewDidDisappearDates: [Date] = []
    override func viewDidDisappear(_ animated: Bool) {
        viewDidDisappearDates.append(Date())
        super.viewDidDisappear(animated)
    }

    var pushViewControllerDates: [Date] = []
    override func push(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerDates.append(Date())
        super.push(viewController, animated: animated)
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

