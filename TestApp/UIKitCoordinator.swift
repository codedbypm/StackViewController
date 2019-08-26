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

    let canPrint = true

    lazy var navigationController: NavigationController = {
        let root = UIViewController.stacked(delegate: self,
                                            color: .yellow)
        let navController = NavigationController(rootViewController: root)
        root.stack = navController

        navController.debugDelegate = self
        navController.delegate = navController
        navController.tabBarItem = UITabBarItem(title: debugPrefix, image: nil, tag: 1)

        return navController
    }()

    var interactionController: InteractivePopAnimator?
}

extension UIKitCoordinator: DebugDelegate {

    var debugPrefix: String {
        return "[UIKit] "
    }

    func debug(_ text: String) {
        guard canPrint else { return }
        print(debugPrefix + text)
    }
}
