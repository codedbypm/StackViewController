//
//  MockViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

class MockViewController: UIViewController {

    var didCallBeginAppearance: Bool? = nil
    var passedIsAppearing: Bool? = nil
    var passedAnimated: Bool? = nil
    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        didCallBeginAppearance = true
        passedIsAppearing = isAppearing
        passedAnimated = animated
    }

    var didCallEndAppearance: Bool? = nil
    override func endAppearanceTransition() {
        didCallEndAppearance = true
    }

    var willMoveToParentDate: Date?
    override func willMove(toParent parent: UIViewController?) {
        willMoveToParentDate = Date()
    }

    var didMoveToParentDate: Date?
    override func didMove(toParent parent: UIViewController?) {
        didMoveToParentDate = Date()        
    }
}

