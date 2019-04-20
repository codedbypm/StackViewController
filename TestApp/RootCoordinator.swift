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

    lazy var tabBarController: UITabBarController = {
        let tabBar = UITabBarController()
        return tabBar
    }()

    let stackCoordinator = StackCoordinator()
    let uikitCoordinator = UIKitCoordinator()
    lazy var stackRootViewController = stackCoordinator.start()
    lazy var uikitRootViewController = uikitCoordinator.start()

    init(window: UIWindow) {
        super.init()

        tabBarController.setViewControllers([stackRootViewController, uikitRootViewController], animated: false)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

