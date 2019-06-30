//
//  MockAnimatedTransitioning.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 30/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
@testable import StackViewController

class MockAnimatedTransitioning: NSObject,  UIViewControllerAnimatedTransitioning {

    var transitionDurationValue: TimeInterval = 0.1
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return transitionDurationValue
    }


    var didCallAnimateTransition: Bool?
    var transitionContext: UIViewControllerContextTransitioning?
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        didCallAnimateTransition = true
        self.transitionContext = transitionContext
    }
}
