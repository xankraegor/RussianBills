//
//  QuickSearchFieldsReporting.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

protocol QuickSearchFieldsReporting: class {
    // Returns names of Object's string type variables
    // That could be used for applying Realm filtering
    static var searchFields: [String] { get }
    static var hasIsCurrent: Bool { get }
}
