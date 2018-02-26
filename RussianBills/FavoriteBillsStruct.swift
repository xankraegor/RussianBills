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
    var updateTimestamps: [Date] = []

    var toDictionary: [String: Any] {
        var values: [String: Double] = [:]
        for (index, element) in billNumbers.enumerated() {
            values[element] = updateTimestamps[index].timeIntervalSince1970
        }
        // ["favoriteBills": [ "123456-7" : 542542542542.23134 , "234467-7" : 542542542324.23134 ]]
        return ["favoriteBills": values]
    }

    // MARK: - Initialization

    init() {
        if let favoriteBills = try? Realm().objects(FavoriteBill_.self) {
            for bill in favoriteBills {
                billNumbers.append(bill.number)
                updateTimestamps.append(bill.favoriteUpdatedTimestamp)
            }
        } else {
            billNumbers = []
            updateTimestamps = []
        }
    }

    init(withValues data: [String: Double]) {
        for item in data {
            billNumbers.append(item.key)
            updateTimestamps.append(Date(timeIntervalSince1970: item.value))
        }
    }
}
