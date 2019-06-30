//
//  TransitionHandling.swift
//  StackViewController
//
//  Created by Paolo Moroni on 09/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandling {

    func performTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning
    )

    func performInteractiveTransition(
        context: TransitionContext,
        interactionController: UIViewControllerInteractiveTransitioning
    )
}
