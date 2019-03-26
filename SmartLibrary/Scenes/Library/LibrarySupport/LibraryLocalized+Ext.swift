//
//  LibraryLocalized+Ext.swift
//  SmartLibrary
//
//  Created by Alexander Yolkin on 1/24/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation

extension String {
    var libraryLocalized: String {
        return NSLocalizedString(self, tableName: "LibraryLocalized", bundle: Bundle.main, value: "", comment: "")
    }
}
