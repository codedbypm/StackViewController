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

// Start
//<TestApp.YellowViewController: 0x7fa817e0a520>: willMove(toParent:)
//<TestApp.YellowViewController: 0x7fa817e0a520>: viewWillAppear
//<TestApp.YellowViewController: 0x7fa817e0a520>: viewDidAppear
//<TestApp.YellowViewController: 0x7fa817e0a520>: didMove(toParent:)

// Next
//<TestApp.PinkViewController: 0x7fa817e19dc0>: willMove(toParent:)
//<TestApp.YellowViewController: 0x7fa817e0a520>: viewWillDisappear
//<TestApp.PinkViewController: 0x7fa817e19dc0>: viewWillAppear
//<TestApp.YellowViewController: 0x7fa817e0a520>: viewDidDisappear
//<TestApp.PinkViewController: 0x7fa817e19dc0>: viewDidAppear
//<TestApp.PinkViewController: 0x7fa817e19dc0>: didMove(toParent:)

// Back
//<TestApp.PinkViewController: 0x7fa817e19dc0>: willMove(toParent:)
//<TestApp.PinkViewController: 0x7fa817e19dc0>: viewWillDisappear
//<TestApp.YellowViewController: 0x7fa817e0a520>: viewWillAppear
//<TestApp.PinkViewController: 0x7fa817e19dc0>: viewDidDisappear
//<TestApp.PinkViewController: 0x7fa817e19dc0>: didMove(toParent:)
//<TestApp.YellowViewController: 0x7fa817e0a520>: viewDidAppear
