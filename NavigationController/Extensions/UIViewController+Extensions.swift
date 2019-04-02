//
//  UIViewController+Extensions.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public extension UIViewController {

    func addChildViewController(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)

        viewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor ).isActive = true

        viewController.didMove(toParent: self)
    }
}
