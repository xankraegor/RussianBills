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
    
    @objc dynamic var name = "notSet"
    @objc dynamic var totalCount = 0

    convenience init(withName: BillsListType, totalCount: Int) {
        self.init()
        name = withName.rawValue
        self.totalCount = totalCount
    }

    let bills = List<Bill_>()
    
    override static func primaryKey() -> String {
        return "name"
    }
}
