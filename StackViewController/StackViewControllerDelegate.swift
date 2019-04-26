//
//  StackViewControllerDelegate.swift
//  StackViewController
//
//  Created by Paolo Moroni on 25/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

public protocol StackViewControllerHandling: UIViewController {
    func popViewController(animated: Bool) -> UIViewController?
    func pushViewController(_: UIViewController, animated: Bool)
}

public protocol StackViewControllerDelegate: class {
    func stackViewController(_: StackViewController,
                             animationControllerFor operation: StackViewController.Operation,
                             from: UIViewController,
                             to: UIViewController) -> UIViewControllerAnimatedTransitioning?

    func stackViewController(_: StackViewController,
                             interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}
