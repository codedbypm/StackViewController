//
//  RootCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 02/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class StackNavigationController: UINavigationController {
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: self)): viewWillAppear")
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: self)): viewDidAppear")
    }
}

class RootCoordinator {

    lazy var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    let stackViewController: StackViewControllerHandling
    let rootViewController = YellowViewController()

    init(window: UIWindow) {
        if true {
            stackViewController = StackViewController(rootViewController: rootViewController)
        } else {
            stackViewController = StackNavigationController(rootViewController: rootViewController)
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
