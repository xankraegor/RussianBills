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

/// Main Synchronization Class
final class SyncMan {

    static let shared = SyncMan() // Singleton

    var foregroundFavoriteBillsUpdateTimer: Timer?

    // MARK: - Initialization

    private init() {

        setupForegroundUpdateTimer()

        iCloudStorage = BillSyncContainerStorage()
        if let storage = iCloudStorage {
            iCloudSyncEngine = IcloudSyncEngine(storage: storage)
        }


        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.uid = user?.uid
        }

        //        setupFavoritesRealmNotificationToken()
        //        setupFavoritesHandle()
    }


    // MARK: - Updating favorite bills

    var favoriteBillsUpdateTimer: DispatchSourceTimer?

    func setupForegroundUpdateTimer(fireNow: Bool = false) {
        foregroundFavoriteBillsUpdateTimer = Timer.scheduledTimer(withTimeInterval: UserDefaultsCoordinator.favoriteBillsUpdateTimeout(), repeats: true, block: { (_) in
            UserServices.updateFavoriteBills(forced: false)
        })

        if fireNow {
            foregroundFavoriteBillsUpdateTimer?.fire()
        }
    }

    var favoriteBillsLastUpdate: Date? {
        let timestamp = UserDefaults.standard.double(forKey: "favoritesUpdateTimestamp")
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        // Set directly by UserServices.updateFavoriteBills function
    }

    func appBadgeToUnseenChangedFavoriteBills(_ usingCount: Int? = nil) {
        let count = usingCount ?? favoriteBillsInRealm?.filter(FavoritesFilters.both.rawValue).count ?? 0
        UIApplication.shared.applicationIconBadgeNumber = count
    }


    // MARK: - iCloud Synchronization

    let icloudDb = CKContainer.default().database(with: .private)
    var iCloudSyncEngine: IcloudSyncEngine? = nil
    var iCloudStorage: BillSyncContainerStorage? = nil

    func isUserLoggedIntoIcloud(withResult: @escaping (Bool)->Void) {
        CKContainer.default().accountStatus(completionHandler: {(_ accountStatus: CKAccountStatus, _ error: Error?) -> Void in
            if accountStatus == .noAccount {
                withResult(false)
            } else {
                withResult(true)
            }
        })
    }

    // MARK: - Firebase synchronization

    private var authHandle: AuthStateDidChangeListenerHandle?
    let firebaseDbLink = Database.database().reference()

    let realm = try? Realm()
    let favoriteBillsInRealm = try? Realm().objects(FavoriteBill_.self)
    var favoritesRealmNotificationToken: NotificationToken? = nil

    var uid: String? = nil
    var isAuthorized: Bool {
        return uid != nil
    }

    func updateFirebaseFavoriteRecords(withCallback: (()->())? = nil) {
        guard let userId = uid else { return }
        let favorites = FavoriteBills().toDictionary
        firebaseDbLink.child(userId).updateChildValues(favorites)
    }

    func setupFavoritesRealmNotificationToken() {
        favoritesRealmNotificationToken = favoriteBillsInRealm?.observe { [weak self] (_)->Void in
            if (self?.isAuthorized)! {
                self?.updateFirebaseFavoriteRecords()
            }
        }
    }

    func setupFavoritesHandle() {
        guard let userId = uid else { return }
        _ = firebaseDbLink.child(userId).child("favoriteBills").observe(DataEventType.value, with: { [weak self] (snapshot) in
            let favoriteBillsInFirebase = snapshot.value as? [String : Double] ?? [:]
            for item in favoriteBillsInFirebase {
                let billNumber = item.key
                let serverTimestamp = item.value
                if let existingBill = self?.realm?.object(ofType: FavoriteBill_.self, forPrimaryKey: billNumber) {

                    // need to update server record :
                    if existingBill.favoriteUpdatedTimestamp.timeIntervalSince1970 > serverTimestamp {
                        // adding new favorite to the server
                        self?.firebaseDbLink.child(userId).child("favoriteBills").setValue([existingBill.number : existingBill.favoriteUpdatedTimestamp.timeIntervalSince1970])
                    } else {
                        // removing a favorite from the server
                        self?.firebaseDbLink.child(userId).child("favoriteBills").child(existingBill.number).removeValue()
                    }
                }

                // !!! CAUTION !!! THIS PART OF CODE PERFORMS CHANGES IN THE LOCAL REALM DATABASE
                // IT IS INTENTIONALLY SWITCHED OFF IN FAVOR OF ICLOUD SYNCHRONIZATION ATM.
                // DO NOT PERFORM SIMULTANOUSLY WITH ICLOUD SYNC

                /*
                 else if existingBill.favoriteUpdatedTimestamp.timeIntervalSince1970 < serverTimestamp { // need to update local record :
                 try? self?.realm?.write {
                 existingBill.favorite = true
                 existingBill.favoriteUpdatedTimestamp = Date(timeIntervalSince1970: serverTimestamp)
                 }
                 }

                 // else: timestamps are equal, nothing to update
                 // (...)

                 } else { // Need to create and load a non-existing bill
                 UserServices.downloadNonExistingBillBySync(withNumber: billNumber, favoriteTimestamp: serverTimestamp)
                 */
            }

        })
    }

}
