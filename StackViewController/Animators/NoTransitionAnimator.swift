//
//  NoTransitionAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 29/08/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public class NoTransitionAnimator: Animator {
    public override func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.0
    }

    public override func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {}
}
