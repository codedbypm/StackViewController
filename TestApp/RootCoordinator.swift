//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class RootCoordinator {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    var stackViewController: StackViewControllerHandling
    let rootViewController = YellowViewController()

    let navControllerDelegate = NavControllerDelegate()

    lazy var navigationController: UINavigationController = {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.delegate = navControllerDelegate
        navController.interactivePopGestureRecognizer?.isEnabled = false
        navController.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        return navController
    }()

    private lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        return recognizer
    }()


    init(window: UIWindow) {
        stackViewController = StackViewController(viewControllers: [rootViewController])
        if false {
            stackViewController = navigationController
        }

        rootViewController.onNext = {
            let pink = PinkViewController()
            pink.onBack = {
                self.stackViewController.popViewController(animated: true)
            }
            self.stackViewController.pushViewController(pink, animated: true)
        }

        window.rootViewController = stackViewController
        window.makeKeyAndVisible()
    }
}

class NavControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
            return HorizontalSlideAnimator(type: .slideIn)
        case .pop:
            return HorizontalSlideAnimator(type: .slideOut)
        default:
            return nil
        }
    }
}
