//
//  Array+Extensions.swift
//  StackViewController
//
//  Created by Paolo Moroni on 02/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {

    var hasDuplicates: Bool {
        return Set(self).count != count
    }
}
