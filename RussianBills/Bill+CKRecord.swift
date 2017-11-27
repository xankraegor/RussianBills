//
//  Bill+CKRecord.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import CloudKit
import RealmSwift

enum BillKey: String {
    case number, name, comments, favorite, favoriteUpdatedTimestamp, favoriteHasUnseenChanges, favoriteHasUnseenChangesTimestamp
}

extension CKRecord {
    subscript(_ key: BillKey) -> CKRecordValue {
        get {
            return self[key.rawValue]!
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}

extension FavoriteBill_ {
    var recordID: CKRecordID {
        return CKRecordID(recordName: number)
    }

    var record: CKRecord {
        let record = CKRecord(recordType: "FavoriteBill", recordID: recordID)

        record[.name] = name as CKRecordValue
        record[.comments] = comments as CKRecordValue
        record[.favoriteUpdatedTimestamp] = favoriteUpdatedTimestamp as CKRecordValue
        record[.favoriteHasUnseenChanges] = favoriteHasUnseenChanges as CKRecordValue
        record[.favoriteHasUnseenChangesTimestamp] = favoriteHasUnseenChangesTimestamp as CKRecordValue
        return record
    }

    // Generates bill marked for download or using a perdownloaded one
    static func from(record: CKRecord) -> FavoriteBill_? {
        let number = record.recordID.recordName
        guard let name = record[.name] as? String,
        let comments = record[.comments] as? String,
        let favoriteUpdatedTimestamp = record[.favoriteUpdatedTimestamp] as? Date,
        let favoriteHasUnseenChanges = record[.favoriteHasUnseenChanges] as? Int,
        let favoriteHasUnseenChangesTimestamp = record[.favoriteHasUnseenChangesTimestamp] as? Date else {
            return nil
        }

        let unseenChanges = favoriteHasUnseenChanges == 0 ? false : true

        let favoriteBill = FavoriteBill_(withNumber: number, name: name, comments: comments, favoriteUpdatedTimestamp: favoriteUpdatedTimestamp, favoriteHasUnseenChanges: unseenChanges, favoriteHasUnseenChangesTimestamp: favoriteHasUnseenChangesTimestamp)

        return favoriteBill
    }
}
