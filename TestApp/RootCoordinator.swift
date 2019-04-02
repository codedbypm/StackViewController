//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import NavigationController

class RootCoordinator {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    let stackViewController: StackViewController

    lazy var rootViewController: UIViewController = {
        let vc = RootViewController()
        vc.didTapNext = { [weak self] in
            self?.stackViewController.show(PinkViewController(), animated: true)
        }
        return vc
    }()

    init(window: UIWindow) {
        stackViewController = StackViewController()
        stackViewController.stack = [rootViewController]        
        window.rootViewController = stackViewController
        window.makeKeyAndVisible()
    }
}
