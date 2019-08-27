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

    var receivedEventDates: [Date] {
        return viewCycleEventDates.compactMap { $0 }
    }

    var viewDidLoadDate: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadDate = Date()
    }

    var viewWillAppearDate: Date?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearDate = Date()
    }

    var viewDidAppearDate: Date?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearDate = Date()
    }
}

