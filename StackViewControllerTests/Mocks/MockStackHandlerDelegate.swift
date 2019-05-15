//
//  Mock.StackHandlerDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 12/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackHandlerDelegate: StackHandlerDelegate {

    var didCallStackDidChange: Bool?
    var stackDidChangeDifference: Stack.Difference?
    func stackDidChange(_ difference: Stack.Difference) {
        self.didCallStackDidChange = true
        self.stackDidChangeDifference = difference
    }
}
