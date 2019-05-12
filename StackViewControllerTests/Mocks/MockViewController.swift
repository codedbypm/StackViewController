//
//  MockViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

class MockViewController: UIViewController {
    var willMoveToParentDate: Date?
    var didMoveToParentDate: Date?
    override func willMove(toParent parent: UIViewController?) { willMoveToParentDate = Date() }
    override func didMove(toParent parent: UIViewController?) { didMoveToParentDate = Date() }
}

