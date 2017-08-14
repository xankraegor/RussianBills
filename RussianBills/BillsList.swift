//
//  BillsList.swift
//  RussianBills
//
//  Created by Xan Kraegor on 13.08.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

/// Any possible ordered list of bills (f.e. to keep order consistency
/// between API response and cached data)
final class BillsList_: Object {
    
    dynamic var name = "notSet"
    let bills = List<Bill_>()
    
    override static func primaryKey() -> String {
        return "name"
    }
    
}
