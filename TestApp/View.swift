//
//  View.swift
//  TestApp
//
//  Created by Paolo Moroni on 01/09/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

class View: UIView, Tracing {

    let name: String

    override var description: String { return name }

    init(_ string: String) {
        name = string
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddSubview(_ subview: UIView) {
        trace(.viewChanges, self, #function, subview)
        super.didAddSubview(subview)
    }

    override func willRemoveSubview(_ subview: UIView) {
        trace(.viewChanges, self, #function, subview)
        super.willRemoveSubview(subview)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        trace(.viewChanges, self, #function, "\(String(describing: newSuperview))")
        super.willMove(toSuperview: newSuperview)
    }

    override func didMoveToSuperview() {
        trace(.viewChanges, self, #function)
        super.didMoveToSuperview()
    }

    override func layoutSubviews() {
        trace(.viewChanges, self, #function)
        super.layoutSubviews()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        trace(.viewChanges, self, #function, "\(String(describing: newWindow))")
        super.willMove(toWindow: newWindow)
    }

    override func didMoveToWindow() {
        trace(.viewChanges, self, #function)
        super.didMoveToWindow()
    }
}
