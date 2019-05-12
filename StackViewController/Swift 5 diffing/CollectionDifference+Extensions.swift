//
//  CollectionDifference+Extensions.swift
//  StackViewController
//
//  Created by Paolo Moroni on 10/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension CollectionDifference {

    static var noDifference: CollectionDifference {
        return CollectionDifference([])!
    }

    var inverted: CollectionDifference? {
        return CollectionDifference(map { $0.inverted })
    }
}

extension CollectionDifference.Change {

    var inverted: CollectionDifference.Change {
        switch self {
        case .insert(offset: let o, element: let e, associatedWith: let a):
            return .remove(offset: o, element: e, associatedWith: a)
        case .remove(offset: let o, element: let e, associatedWith: let a):
            return .insert(offset: o, element: e, associatedWith: a)
        }
    }
}
