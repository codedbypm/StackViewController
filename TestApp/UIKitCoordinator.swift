//
//  UIKitCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class UIKitCoordinator: NSObject {

    lazy var navigationController: NavigationController = {
        let root = UIViewController.colored(.yellow)
        let navController = NavigationController()
        root.stack = navController

        navController.delegate = navController
        navController.tabBarItem = UITabBarItem(title: String(describing: navController),
                                                image: nil,
                                                tag: 1)
        return navController
    }()

    var interactionController: InteractivePopAnimator?
}
