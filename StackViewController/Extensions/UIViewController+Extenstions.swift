//
//  UIViewController+Extenstions.swift
//  StackViewController
//
//  Created by Paolo Moroni on 30/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

extension UIViewController {

    /// A boolean value indicating whether the view controller's `view` is added to the view
    /// hierarchy
    var isInViewHierarchy: Bool {
        return isViewLoaded && view.window != nil
    }

    func addChildren(_ viewControllers: [UIViewController]) {
        viewControllers.forEach { addChild($0) }
    }
}
