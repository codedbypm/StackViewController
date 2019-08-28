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

    var viewCycleEventDates: [Date?] {
        return [
            viewDidLoadDate,
            viewWillAppearDate,
            viewDidAppearDate
        ]
    }

    var stackOperationDates: [Date?] {
        return [pushViewControllerDate]
    }

    var receivedEventDates: [Date] {
        return (viewCycleEventDates + stackOperationDates).compactMap { $0 }.sorted()
    }

    var isViewLoadedFlag = false
    override var isViewLoaded: Bool {
        return isViewLoadedFlag
    }

    var viewDidLoadDate: Date?
    override func viewDidLoad() {
        viewDidLoadDate = Date()
        super.viewDidLoad()
    }

    var viewWillAppearDate: Date?
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearDate = Date()
    }

    var viewDidAppearDate: Date?
    override func viewDidAppear(_ animated: Bool) {
        viewDidAppearDate = Date()
    }

    var pushViewControllerDate: Date?
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerDate = Date()
        super.pushViewController(viewController, animated: animated)
    }
}

