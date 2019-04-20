//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class RootCoordinator: NSObject {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    lazy var tabBarController: UITabBarController = {
        let tabBar = UITabBarController()
        return tabBar
    }()

    lazy var stackViewController: StackViewController = {
        let stack = StackViewController(viewControllers: [yellowViewController])
        stack.tabBarItem = UITabBarItem(title: "Stack", image: nil, tag: 1)
        return stack
    }()

    lazy var navigationController: UINavigationController = {
        let navController = UINavigationController(rootViewController: yellowViewController)
        navController.delegate = self
        navController.tabBarItem = UITabBarItem(title: "UIKit", image: nil, tag: 1)
        return navController
    }()

    var stackController: StackViewControllerHandling? {
        return tabBarController.selectedViewController as? StackViewControllerHandling
    }

    var yellowViewController: UIViewController {
        let yellow = YellowViewController()
        yellow.onNext = {
            let pink = PinkViewController()
            pink.onBack = {
                self.stackController?.popViewController(animated: true)
            }
            self.stackController?.pushViewController(pink, animated: true)
        }
        return yellow
    }

    var operation: UINavigationController.Operation = .none

    init(window: UIWindow) {
        super.init()

        tabBarController.setViewControllers([stackViewController, navigationController], animated: false)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension RootCoordinator: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        self.operation = operation

        switch operation {
        case .push:
            return HorizontalSlideAnimationController(type: .slideIn)
        case .pop:
            return HorizontalSlideAnimationController(type: .slideOut)
        default:
            return nil
        }
    }
}

