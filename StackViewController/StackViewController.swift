//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public class StackViewController: UIViewController {

    // MARK: - Public properties

    public var stack: [UIViewController] = []
//    {
//        didSet {
//            guard let topViewController = stack.last else { return }
//            addChild(topViewController)
//            view.addSubview(topViewController.view)
//            topViewController.view.pinEdges(to: view)
//            topViewController.didMove(toParent: self)
//        }
//    }

    public var rootViewController: UIViewController? {
        return stack.first
    }

    public var topViewController: UIViewController? {
        return stack.last
    }

    // MARK: - Init

    public required init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        stack.append(rootViewController)

        addChild(rootViewController)
        view.addSubview(rootViewController.view)
        rootViewController.view.pinEdges(to: view)
        rootViewController.didMove(toParent: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public methods

    public func show(_ viewController: UIViewController, animated: Bool) {
        guard let from = topViewController else {
            assertionFailure("Error: there is no `from` viewController")
            return
        }

        // 1. Configure objects
        let to = viewController
        let context = StackViewControllerTransitionContext(from: from,
                                                           to: viewController,
                                                           containerView: view,
                                                           transitionType: .slideIn)
        context.isAnimated = animated

        // 2. Store toViewController
        stack.append(to)

        // 3. Inform parent view controller
        from.willMove(toParent: nil)
        to.willMove(toParent: self)

        // 4. Add to as child viewController
        addChild(to)

        let animator = HorizontalSlideAnimator(direction: .slideIn)
        animator.animateTransition(using: context)
    }

    public func hide(_ viewController: UIViewController, animated: Bool) {
        guard viewController === topViewController else {
            assertionFailure("Error: Cannot hide a view controller which is not on top of the stack")
            return
        }

        // 1. Configure objects
        let from = viewController
        let toIndex = stack.firstIndex(of: from)?.advanced(by: -1)
        let to = stack[toIndex!]

        let context = StackViewControllerTransitionContext(from: from,
                                                           to: to,
                                                           containerView: view,
                                                           transitionType: .slideOut)
        context.isAnimated = animated

        // 2. Remove fromViewController
        stack.removeLast()

        // 3. Inform parent view controller
        from.willMove(toParent: nil)
        to.willMove(toParent: self)

        let animator = HorizontalSlideAnimator(direction: .slideOut)
        animator.animateTransition(using: context)

    }
}

public extension StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
