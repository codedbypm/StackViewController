//
//  StackViewControllerDelegate.swift
//  StackViewController
//
//  Created by Paolo Moroni on 25/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

public protocol StackViewControllerDelegate: class {
    func animationController(for operation: StackViewController.Operation,
                             from: UIViewController,
                             to: UIViewController) -> UIViewControllerAnimatedTransitioning?

    func interactionController(for animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

public protocol StackViewControllerHandling: UIViewController {
    var viewControllers: [UIViewController] { get set }
    @discardableResult func popViewController(animated: Bool) -> UIViewController?
    func pushViewController(_: UIViewController, animated: Bool)
    func setViewControllers(_: [UIViewController], animated: Bool)
    func popToRootViewController(animated: Bool) -> [UIViewController]?
}
