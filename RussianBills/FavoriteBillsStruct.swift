//
//  FavoriteBillsStruct.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

struct FavoriteBills {

    var bills: [String]

    var toAnyObject: Any {
        return [
            "bills" : bills
        ]
    }

    // MARK: - Initialization

    init() {
        if let favoriteBills = try? Realm().objects(Bill_.self).filter("favorite == true") {
            bills = Array(favoriteBills.map{$0.number}).sorted()
        } else {
            bills = []
        }
    }

    init(withData data: [String]) {
        bills = data
    }
}
