//
//  MockInteractiveTransitioning.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 30/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
@testable import StackViewController

class MockInteractiveTransitioning: NSObject,  UIViewControllerInteractiveTransitioning {

    var didCallStartInteractiveTransition: Bool?
    var transitionContext: UIViewControllerContextTransitioning?
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        didCallStartInteractiveTransition = true
        self.transitionContext = transitionContext
    }

}
