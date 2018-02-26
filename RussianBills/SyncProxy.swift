//
//  BillSyncContainer.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import CloudKit

public struct SyncProxy {
    public let number: String
    public let name: String
    public let comments: String
    public let note: String
    public var favoriteUpdatedTimestamp: Date
    public var favoriteHasUnseenChanges: Bool
    public var favoriteHasUnseenChangesTimestamp: Date
    // Non-required value which is set by init(withFavoriteBill:) only
    public var markedToBeRemovedFromFavorites: Bool? = nil

    public init(withNumber number: String, name: String, comments: String, note: String, favoriteUpdatedTimestamp: Date, favoriteHasUnseenChanges: Bool, favoriteHasUnseenChangesTimestamp: Date) {
        self.number = number
        self.name = name
        self.comments = comments
        self.note = note
        self.favoriteUpdatedTimestamp = favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = favoriteHasUnseenChanges
        self.favoriteHasUnseenChangesTimestamp = favoriteHasUnseenChangesTimestamp
    }
}

extension SyncProxy: Equatable {
    public static func ==(lhs: SyncProxy, rhs: SyncProxy) -> Bool {
        return lhs.number == rhs.number
                && lhs.name == rhs.name
                && lhs.comments == rhs.comments
                && lhs.note == rhs.note
                && lhs.favoriteUpdatedTimestamp == rhs.favoriteUpdatedTimestamp
                && lhs.favoriteHasUnseenChanges == rhs.favoriteHasUnseenChanges
                && lhs.favoriteHasUnseenChangesTimestamp == rhs.favoriteHasUnseenChangesTimestamp
    }
}

extension SyncProxy: CustomStringConvertible {

    public var description: String {
        return "Sync proxy of \(self.number)|:|\(self.name)|:|\(self.comments)|:|\(self.note)|:|\(self.favoriteUpdatedTimestamp)|:|\(favoriteHasUnseenChanges)|:|\(favoriteHasUnseenChangesTimestamp)|:|\(markedToBeRemovedFromFavorites ?? false)"
    }

}

// MARK: - SyncProxy + FavoriteBill_

extension SyncProxy {
    init(withFavoriteBill bill: FavoriteBill_) {
        self.number = bill.number
        self.name = bill.name
        self.comments = bill.comments
        self.note = bill.note
        self.favoriteUpdatedTimestamp = bill.favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = bill.favoriteHasUnseenChanges
        self.favoriteHasUnseenChangesTimestamp = bill.favoriteHasUnseenChangesTimestamp
        self.markedToBeRemovedFromFavorites = bill.markedToBeRemovedFromFavorites
    }

    var favoriteBill: FavoriteBill_ {
        let favoriteBill = FavoriteBill_()
        favoriteBill.number = self.number
        favoriteBill.comments = self.comments
        favoriteBill.note = self.note
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

// MARK: - FavoriteBill_ + SyncProxy

extension FavoriteBill_ {
    var syncProxy: SyncProxy {
        let container = SyncProxy(withNumber: self.number, name: self.name, comments: self.comments, note: self.note, favoriteUpdatedTimestamp: self.favoriteUpdatedTimestamp, favoriteHasUnseenChanges: self.favoriteHasUnseenChanges, favoriteHasUnseenChangesTimestamp: self.favoriteHasUnseenChangesTimestamp)
        return container
    }
}

// MARK: - CKRecord + SyncProxy

extension SyncProxy {

    init(withRecord record: CKRecord) {
        self.number = record.recordID.recordName
        self.name = record[.name] as! String
        self.comments = record[.comments] as! String
        self.note = record[.note] as! String
        self.favoriteUpdatedTimestamp = record[.favoriteUpdatedTimestamp] as! Date
        self.favoriteHasUnseenChanges = (record[.favoriteHasUnseenChanges] as! Int) == 0 ? false : true
        self.favoriteHasUnseenChangesTimestamp = record[.favoriteHasUnseenChangesTimestamp] as! Date
    }

    var recordID: CKRecordID {
        return CKRecordID(recordName: number)
    }

    var record: CKRecord {
        let record = CKRecord(recordType: "FavoriteBill", recordID: recordID)
        record[.name] = name as CKRecordValue
        record[.comments] = comments as CKRecordValue
        record[.note] = note as CKRecordValue
        record[.favoriteUpdatedTimestamp] = favoriteUpdatedTimestamp as CKRecordValue
        record[.favoriteHasUnseenChanges] = favoriteHasUnseenChanges as CKRecordValue
        record[.favoriteHasUnseenChangesTimestamp] = favoriteHasUnseenChangesTimestamp as CKRecordValue
        return record
    }

}
