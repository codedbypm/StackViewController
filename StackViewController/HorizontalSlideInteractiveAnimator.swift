//
//  HorizontalSlideInteractiveAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 12/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

class HorizontalSlideInteractiveAnimator: NSObject {

    let animator: UIViewControllerAnimatedTransitioning

    init(animator: UIViewControllerAnimatedTransitioning) {
        self.animator = animator
    }

    public func updateInteractiveTransition(_ percentage: CGFloat) {
        
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension HorizontalSlideInteractiveAnimator: UIViewControllerInteractiveTransitioning {

    public func startInteractiveTransition(_ context: UIViewControllerContextTransitioning) {

        animator.animateTransition(using: context)
    }
}
