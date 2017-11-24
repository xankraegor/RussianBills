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
    public let comments: String
    public var favoriteUpdatedTimestamp : Date
    public var favoriteHasUnseenChanges: Bool
    public var favoriteHasUnseenChangesTimestamp: Date

    public init(withNumber number: String, name: String, comments: String, favoriteUpdatedTimestamp: Date, favoriteHasUnseenChanges: Bool, favoriteHasUnseenChangesTimestamp: Date) {
        self.number = number
        self.name = name
        self.comments = comments
        self.favoriteUpdatedTimestamp = favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = favoriteHasUnseenChanges
        self.favoriteHasUnseenChangesTimestamp = favoriteHasUnseenChangesTimestamp
    }
}

extension BillSyncContainer: Equatable {
    public static func ==(lhs: BillSyncContainer, rhs: BillSyncContainer) -> Bool {
        return lhs.number == rhs.number
            && lhs.name == rhs.name
            && lhs.comments == rhs.comments
            && lhs.favoriteUpdatedTimestamp == rhs.favoriteUpdatedTimestamp
            && lhs.favoriteHasUnseenChanges == rhs.favoriteHasUnseenChanges
         && lhs.favoriteHasUnseenChangesTimestamp == rhs.favoriteHasUnseenChangesTimestamp
    }
}


// MARK: - BillSyncContainer + FavoriteBill_

extension BillSyncContainer {
    init(withFavoriteBill bill: FavoriteBill_) {
        self.number = bill.number
        self.name = bill.name
        self.comments = bill.comments
        self.favoriteUpdatedTimestamp = bill.favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = bill.favoriteHasUnseenChanges
        self.favoriteHasUnseenChangesTimestamp = bill.favoriteHasUnseenChangesTimestamp
    }

    var favoriteBill: FavoriteBill_ {
        let favoriteBill = FavoriteBill_()
        favoriteBill.number = self.number
        favoriteBill.comments = self.comments
        favoriteBill.name = self.name
        favoriteBill.favoriteHasUnseenChanges = self.favoriteHasUnseenChanges
        favoriteBill.favoriteUpdatedTimestamp = self.favoriteUpdatedTimestamp
        favoriteBill.favoriteHasUnseenChangesTimestamp = self.favoriteHasUnseenChangesTimestamp
        if favoriteBill.bill == nil {
            favoriteBill.markedForDownload = true
        }
        return favoriteBill
    }
}

// MARK: - FavoriteBill_ + BillSyncContainer

extension FavoriteBill_ {
    var billSyncContainer: BillSyncContainer {
        let container = BillSyncContainer(withNumber: self.number, name: self.name, comments: self.comments, favoriteUpdatedTimestamp: self.favoriteUpdatedTimestamp, favoriteHasUnseenChanges: self.favoriteHasUnseenChanges, favoriteHasUnseenChangesTimestamp: self.favoriteHasUnseenChangesTimestamp)
        return container
    }
}
