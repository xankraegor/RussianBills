//
//  SynchronizationManager.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import RealmSwift
import UserNotifications
import CloudKit

final class SyncMan {
    // Singletone
    static let shared = SyncMan()

    private var authHandle: AuthStateDidChangeListenerHandle?
    let firebaseDbLink = Database.database().reference()
    let icloudDb = CKContainer.default().database(with: .private)

    var uid: String? = nil
    var isAuthorized: Bool {
        return uid != nil
    }

    let realm = try? Realm()
    let favoriteBillsInRealm = try? Realm().objects(FavoriteBill_.self)
    var favoritesRealmNotificationToken: NotificationToken? = nil

    // MARK: - Initialization

    private init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.uid = user?.uid
        }

//        setupFavoritesRealmNotificationToken()
//        setupFavoritesHangle()
    }

    // MARK: - Firebase syncronization

//    func updateFirebaseFavoriteRecords(withCallback: (()->())? = nil) {
//        guard let userId = uid else { return }
//        let favorites = FavoriteBills().toDictionary
////        debugPrint(favorites)
//        firebaseDbLink.child(userId).updateChildValues(favorites)
//    }
//
//    func setupFavoritesRealmNotificationToken() {
//        favoritesRealmNotificationToken = favoriteBillsInRealm?.observe { [weak self] (_)->Void in
//            if (self?.isAuthorized)! {
//                self?.updateFirebaseFavoriteRecords()
//            }
//        }
//    }
//
//    func setupFavoritesHangle() {
//        guard let userId = uid else { return }
//        let refHandle = firebaseDbLink.child(userId).child("favoriteBills").observe(DataEventType.value, with: { [weak self] (snapshot) in
//            let favoriteBillsInFirebase = snapshot.value as? [String : Double] ?? [:]
//            for item in favoriteBillsInFirebase {
//                let billNumber = item.key
//                let serverTimestamp = item.value
//                if let existingBill = self?.realm?.object(ofType: Bill_.self, forPrimaryKey: billNumber) {
//
//                    // need to update server record :
//                    if existingBill.favoriteUpdatedTimestamp.timeIntervalSince1970 > serverTimestamp {
//                        if existingBill.favorite {
//                            // adding new favorite to the server
//                            self?.firebaseDbLink.child(userId).child("favoriteBills").setValue([existingBill.number : existingBill.favoriteUpdatedTimestamp.timeIntervalSince1970])
//                        } else {
//                            // removing a favorite from the server
//                            self?.firebaseDbLink.child(userId).child("favoriteBills").child(existingBill.number).removeValue()
//                        }
//
//                        // need to update local record :
//                    } else if existingBill.favoriteUpdatedTimestamp.timeIntervalSince1970 < serverTimestamp {
//                        try? self?.realm?.write {
//                            existingBill.favorite = true
//                            existingBill.favoriteUpdatedTimestamp = Date(timeIntervalSince1970: serverTimestamp)
//                        }
//                    }
//
//                    // else: timestamps are equal, nothing to update
//                    // (...)
//
//                } else { // Need to create and load a non-existing bill
//                    UserServices.downloadNonExistingBillBySync(withNumber: billNumber, favoriteTimestamp: serverTimestamp)
//                }
//            }
//        })
//    }


    // MARK: - Updating favorite bills

    var favoriteBillsUpdateTimer: DispatchSourceTimer?

    var favoriteBillsLastUpdate: Date? {
        let timestamp = UserDefaults.standard.double(forKey: "favoritesUpdateTimestamp")
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        // Set directly by UserServices.updateFavoriteBills function
    }

    // MARK: - Lesson 5

    //    func setupIColud() {
    //
    //        // Должна быть авторизация!
    //
    //
    //        let publicDatabase = container.database(with: .public)
    //        let privateDatabase = container.database(with: .private)
    //
    //        let catId = CKRecordID(recordName: "CatTree")
    //        let cat = CKRecord(recordType: "Cat", recordID: catId)
    //        cat["color"] = "Зеленая" as NSString
    //        cat["masterName"] = "Пётр" as NSString
    //
    //        database.save(cat) {
    //            (record, error) in
    //            if let error = error {
    //                // Insert error hangle
    //                return
    //            }
    //            // Insert sucessfully saved record code
    //        }
    //
    ////        let catId = CKREcord(recordName: "CatTree")
    ////        database.fetch(withRecordID: catId) {
    ////            cat, error init
    ////            print(cat, error)
    ////        }
    //
    //        let query = CKQuery(recordType: "Cats", predicate: NSPredicate(value: true))
    //        let zoneId = CKRecordZoneID(zoneName: "_defaultZone", ownerNmae: "_043927439047320949302fr4324")
    //
    //        database.perform(query, inZoneWith: zoneID) {
    //            cats, error in
    //            for cat in cats! {
    //                print(cat["color"])
    //            }
    //        }
    //
    //    }

    // MARK: - iCloud Syncronization

    func isUserLoggedIntoIcloud(withResult: @escaping (Bool)->Void) {
        CKContainer.default().accountStatus(completionHandler: {(_ accountStatus: CKAccountStatus, _ error: Error?) -> Void in
            if accountStatus == .noAccount {
                withResult(false)
            } else {
                withResult(true)
            }
        })
    }

    func writeToIcloud() {
        guard let favs = favoriteBillsInRealm else { return }

        let records : [CKRecord] = favs.map{ CKRecord(recordType: "FavoriteBill", recordID: CKRecordID(recordName: $0.number)) }

        records.forEach { (record) in
            icloudDb.save(record, completionHandler: { (responseRecord, error) in
                if let error = error {
                    debugPrint("∆ Error while writing data to iCloud: \(error.localizedDescription)")
                    return
                }
            })
        }
    }

    func fetchAndModifyRecords() {
//        guard let favs = favoriteBillsInRealm else { return }
//        let recordIDs = Array(favs).map{ CKRecordID(recordName: $0.name ) }

        var fetchedRecords: [CKRecord] = []
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "FavoriteBill", predicate: predicate)
        let operation = CKQueryOperation(query: query)


        operation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }

        operation.queryCompletionBlock = { cursor, error in
            print(fetchedRecords)
        }

        icloudDb.add(operation)
    }

}
