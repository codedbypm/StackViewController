//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

class RootCoordinator: NSObject {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    lazy var tabBarController = UITabBarController()

    let stackCoordinator = StackCoordinator()
    let uikitCoordinator = UIKitCoordinator()

    lazy var stackViewController = stackCoordinator.stackViewController
    lazy var navigationController = uikitCoordinator.navigationController

    init(window: UIWindow) {
        super.init()

        tabBarController.setViewControllers([stackViewController, navigationController], animated: false)
        tabBarController.selectedViewController = navigationController

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

