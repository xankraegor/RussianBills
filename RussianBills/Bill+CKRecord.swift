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
    case number, name, favorite, favoriteUpdatedTimestamp, favoriteHasUnseenChanges//, favoriteHasUnseenChangesTimestamp
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

extension Bill_ {
    var recordID: CKRecordID {
        return CKRecordID(recordName: number)
    }

    var record: CKRecord {
        let record = CKRecord(recordType: "FavoriteBill", recordID: recordID)
        record[.favorite] = favorite as CKRecordValue
        record[.favoriteUpdatedTimestamp] = favoriteUpdatedTimestamp as CKRecordValue
        record[.favoriteHasUnseenChanges] = favoriteHasUnseenChanges as CKRecordValue
//        record[.favoriteHasUnseenChangesTimestamp] = favoriteHasUnseenChangesTimestamp as CKRecordValue
        return record
    }

    // Generates bill marked for download or using a perdownloaded one
    static func from(record: CKRecord) -> Bill_? {
        guard  let number = record[.number] as? String,
        let name = record[.name] as? String,
        let favorite = record[.favorite] as? Int,
        let favoriteUpdatedTimestamp = record[.favoriteUpdatedTimestamp] as? Date,
        let favoriteHasUnseenChanges = record[.favoriteHasUnseenChanges] as? Int/*,
        let favoriteHasUnseenChangesTimestamp = record[.favoriteHasUnseenChangesTimestamp] as? Date*/ else {
            return nil
        }

        if let downloadedBill = try! Realm().object(ofType: Bill_.self, forPrimaryKey: number) {
            let newBill = downloadedBill.copy() as! Bill_
            newBill.favorite = favorite == 0 ? false : true
            newBill.favoriteUpdatedTimestamp = favoriteUpdatedTimestamp
            newBill.favoriteHasUnseenChanges = favoriteHasUnseenChanges == 0 ? false : true
//            newBill.favoriteHasUnseenChangesTimestamp = favoriteHasUnseenChangesTimestamp
            return newBill
        } else {
            let favBool = favorite == 0 ? false : true
            let chngBool = favoriteHasUnseenChanges == 0 ? false : true
            let bill = Bill_(markedToDownloadWithNumber: number, name: name, favorite: favBool, favoriteUpdatedTimestamp: favoriteUpdatedTimestamp, favoriteHasUnseenChanges: chngBool/*, favoriteHasUnseenChangesTimestamp: favoriteHasUnseenChangesTimestamp*/)
            return bill
        }
    }
}
