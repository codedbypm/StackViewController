//
//  TransitionHandling.swift
//  StackViewController
//
//  Created by Paolo Moroni on 09/06/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol TransitionHandling {

    func prepareTransition(context: TransitionContext)
    
    func performTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning
    )

    func performInteractiveTransition(
        context: TransitionContext,
        animationController: UIViewControllerAnimatedTransitioning,
        interactionController: UIViewControllerInteractiveTransitioning
    )
}
