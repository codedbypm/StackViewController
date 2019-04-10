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
    let stackViewController: StackViewControllerHandling
    let rootViewController = YellowViewController()

    let navControllerDelegate = NavControllerDelegate()

    init(window: UIWindow) {
        if true {
            stackViewController = StackViewController(viewControllers: [rootViewController])
        } else {
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.delegate = navControllerDelegate
            stackViewController = navController
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
