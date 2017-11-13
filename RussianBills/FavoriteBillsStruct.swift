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

    var billNumbers: [String] = []
    var updateTimestamps: [Double] = []

    var toDictionary: [String: Any] {
        var values : [String : Double] = [:]
        for (index, element) in billNumbers.enumerated() {
            values[element] = updateTimestamps[index]
        }

        return [ "favoriteBills" : values ]
        // ["favoriteBills": [ "123456-7" : 542542542542.23134 , "234467-7" : 542542542324.23134 ]]
    }


    // MARK: - Initialization

    init() {
        if let favoriteBills = try? Realm().objects(Bill_.self).filter("favorite == true") {
            for bill in favoriteBills {
                billNumbers.append(bill.number)
                updateTimestamps.append(bill.favoriteUpdated)
            }
        } else {
            billNumbers = []
            updateTimestamps = []
        }
    }

    init(withValues data: [String : Double]) {
        for item in data {
            billNumbers.append(item.key)
            updateTimestamps.append(item.value)
        }
    }
}
