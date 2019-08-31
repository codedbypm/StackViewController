//
//  StackCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//


import StackViewController

class StackCoordinator {

    lazy var stackViewController: StackViewController = {
        var root = BaseViewController.colored(.black)
        let stackViewController = StackViewController(rootViewController: root)
        root.stack = stackViewController

        let tabBarTitle = String(describing: stackViewController)
        stackViewController.tabBarItem = UITabBarItem(title: tabBarTitle,
                                                      image: nil,
                                                      tag: 1)

        return stackViewController
    }()
}

extension StackViewController: StackViewControllerHandling {
    public func setViewControllers(_ stack: [UIViewController], animated: Bool) {
        setStack(stack, animated: animated)
    }
}
