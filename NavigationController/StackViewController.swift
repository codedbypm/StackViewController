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

    public var stack: [UIViewController] = [] {
        didSet {
            guard let topViewController = stack.last else { return }
            addChildViewController(topViewController)
        }
    }

    public var rootViewController: UIViewController? {
        return stack.first
    }

    // MARK: - Init

    public required init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        stack.append(rootViewController)
        addChildViewController(rootViewController)
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public methods

    public func show(_ viewController: UIViewController, animated: Bool) {
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .custom
//        viewController.modalTransitionStyle = .coverVertical

        stack.append(viewController)
        present(viewController, animated: true, completion: nil)
    }
}

public extension StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension StackViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HorizontalSlideAnimator()
    }
}
