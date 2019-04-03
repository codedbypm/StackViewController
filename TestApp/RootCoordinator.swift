//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

class RootCoordinator {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    let stackViewController: StackViewController
    let rootViewController = YellowViewController()

    init(window: UIWindow) {
        stackViewController = StackViewController(rootViewController: rootViewController)
        rootViewController.didTapNext = {
            self.stackViewController.show(PinkViewController(), animated: true)
        }
        window.rootViewController = stackViewController
        window.makeKeyAndVisible()
    }
}
