//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public protocol StackViewControllerHandling: UIViewController {
    init(rootViewController: UIViewController)
    func popViewController(animated: Bool) -> UIViewController?
    func pushViewController(_: UIViewController, animated: Bool)
}

public class StackViewController: UIViewController, StackViewControllerHandling {

    // MARK: - Public properties

    public var stack: [UIViewController] = []

    public var rootViewController: UIViewController?

    public var topViewController: UIViewController? {
        return stack.last
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    // MARK: - Init

    public required init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard isViewLoaded else {
            return
        }

        guard let from = topViewController else {
            stack.append(viewController)

            addChild(viewController)
            view.addSubview(viewController.view)
            viewController.view.pinEdgesToSuperView()
            viewController.didMove(toParent: self)
            return
        }

        stack.append(viewController)

        let to = viewController
        let context = StackViewControllerTransitionContext(from: from,
                                                           to: viewController,
                                                           containerView: view,
                                                           transitionType: .slideIn)
        context.isAnimated = animated

        // 3. Inform from that will be removed from his parent
        from.willMove(toParent: nil)

        // 4. Add to as child viewController
        addChild(to)

        let animator = HorizontalSlideAnimator()
        animator.animateTransition(using: context)
    }

    public func popViewController(animated: Bool) -> UIViewController? {
        guard let viewController = topViewController else {
            assertionFailure("Error: Cannot hide a view controller which is not on top of the stack")
            return nil
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

        let animator = HorizontalSlideAnimator()
        animator.animateTransition(using: context)

        return nil
    }
}

public extension StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let rootViewController = rootViewController {
            pushViewController(rootViewController, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
    }
}
