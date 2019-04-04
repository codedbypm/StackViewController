//
//  UIView+Extensions.swift
//  StackViewController
//
//  Created by Paolo Moroni on 03/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

extension UIView {

    func pinEdgesToSuperView() {
        guard let superView = superview else { return }
        
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor ).isActive = true
    }
}
