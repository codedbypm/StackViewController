//
//  Collection+Extensions.swift
//  StackViewController
//
//  Created by Paolo Moroni on 03/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension Collection {
    // Utility method for collections that wish to implement
    // CustomStringConvertible and CustomDebugStringConvertible using a bracketed
    // list of elements, like an array.
    func _makeCollectionDescription(
        withTypeName type: String? = nil
        ) -> String {
        var result = ""
        if let type = type {
            result += "\(type)(["
        } else {
            result += "["
        }

        var first = true
        for item in self {
            if first {
                first = false
            } else {
                result += ", "
            }
            debugPrint(item, terminator: "", to: &result)
        }
        result += type != nil ? "])" : "]"
        return result
    }
}
