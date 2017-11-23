//
//  BillSyncContainer.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

public struct BillSyncContainer {
    public let number: String
    public let name: String
    public var favorite: Bool
    public var favoriteUpdatedTimestamp : Date
    public var favoriteHasUnseenChanges: Bool
//    public var favoriteHasUnseenChangesTimestamp: Date

    public init(withNumber number: String, name: String, favorite: Bool, favoriteUpdatedTimestamp: Date, favoriteHasUnseenChanges: Bool/*, favoriteHasUnseenChangesTimestamp: Date*/) {
        self.number = number
        self.name = name
        self.favorite = favorite
        self.favoriteUpdatedTimestamp = favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = favoriteHasUnseenChanges
//        self.favoriteHasUnseenChangesTimestamp = favoriteHasUnseenChangesTimestamp
    }
}

extension BillSyncContainer: Equatable {
    public static func ==(lhs: BillSyncContainer, rhs: BillSyncContainer) -> Bool {
        return lhs.number == rhs.number
            && lhs.favorite == rhs.favorite
            && lhs.favoriteUpdatedTimestamp == rhs.favoriteUpdatedTimestamp
            && lhs.favoriteHasUnseenChanges == rhs.favoriteHasUnseenChanges
//         && lhs.favoriteHasUnseenChangesTimestamp == rhs.favoriteHasUnseenChangesTimestamp
    }
}


// MARK: - BillSyncContainer + Bill_

extension BillSyncContainer {
    init(withBill bill: Bill_) {
        self.number = bill.number
        self.name = bill.name
        self.favorite = bill.favorite
        self.favoriteUpdatedTimestamp = bill.favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = bill.favoriteHasUnseenChanges
//        self.favoriteHasUnseenChangesTimestamp = bill.favoriteHasUnseenChangesTimestamp
    }

    var bill: Bill_ {
        // Bill is already downloaded
        if let bill = try! Realm().object(ofType: Bill_.self, forPrimaryKey: self.number) {
            let newBill = bill.copy() as! Bill_
            newBill.favorite = self.favorite
            newBill.favoriteUpdatedTimestamp = self.favoriteUpdatedTimestamp
            newBill.favoriteHasUnseenChanges = self.favoriteHasUnseenChanges
//            newBill.favoriteHasUnseenChangesTimestamp = self.favoriteHasUnseenChangesTimestamp
            return newBill
        } else { // Bill will be marked to download!
            return Bill_(markedToDownloadWithNumber: self.number, name: self.name, favorite: self.favorite, favoriteUpdatedTimestamp: self.favoriteUpdatedTimestamp, favoriteHasUnseenChanges: self.favoriteHasUnseenChanges/*, favoriteHasUnseenChangesTimestamp: self.favoriteHasUnseenChangesTimestamp*/)
        }
    }
}

// MARK: - Bill_ + BillSyncContainer

extension Bill_ {
    var billSyncContainer: BillSyncContainer {
        let container = BillSyncContainer(withNumber: self.number, name: self.name, favorite: self.favorite, favoriteUpdatedTimestamp: self.favoriteUpdatedTimestamp, favoriteHasUnseenChanges: self.favoriteHasUnseenChanges/*, favoriteHasUnseenChangesTimestamp: self.favoriteHasUnseenChangesTimestamp*/)
        return container
    }
}
