//
//  PopAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

//TODO: remove this public
public class PopAnimator: Animator {
    
    override func prepareTransition(using context: UIViewControllerContextTransitioning) {
        super.prepareTransition(using: context)

        guard let from = context.viewController(forKey: .from) else { return }
        guard let to = context.viewController(forKey: .to) else { return }
        
        let containerView = context.containerView
        containerView.insertSubview(to.view, belowSubview: from.view)
        
        let initialOffsetX = containerView.frame.width * (-0.3)
        to.view.frame = containerView.bounds.offsetBy(dx: initialOffsetX, dy: 0.0)
    }
    
    override func transitionAnimations(using context: UIViewControllerContextTransitioning) -> Animations {
        return { [weak self] in
            guard let self = self else { return }

            guard let from = context.viewController(forKey: .from) else { return }
            from.view.frame = self.frameOfViewWhenOffScreen

            guard let to = context.viewController(forKey: .to) else { return }
            to.view.frame = context.finalFrame(for: to)
        }
    }
}

