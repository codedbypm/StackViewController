//
//  HorizontalSlideInteractiveAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 12/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

class HorizontalSlideInteractiveAnimator: NSObject, UIViewControllerInteractiveTransitioning {

    let animator: UIViewControllerAnimatedTransitioning

    init(animator: UIViewControllerAnimatedTransitioning) {
        self.animator = animator
    }

    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {


    }
}
