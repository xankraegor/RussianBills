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

final class SyncMan {
    // Singletone
    static let shared = SyncMan()

    private var authHandle: AuthStateDidChangeListenerHandle?
    let dbLink = Database.database().reference()

    var uid: String? = nil
    var isAuthorized: Bool {
        return uid != nil
    }

    let realm = try? Realm()
    let favoriteBillsInRealm = try? Realm().objects(Bill_.self).filter("favorite == true")

    var favoritesRealmNotificationToken: NotificationToken? = nil

    private init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.uid = user?.uid
        }

        setupFavoritesRealmNotificationToken()
        setupFavoritesHangle()
    }

    func updateFirebaseFavoriteRecords(withCallback: (()->())? = nil) {
        guard let userId = uid else { return }
        let favorites = FavoriteBills().toDictionary
        debugPrint(favorites)
        dbLink.child(userId).updateChildValues(favorites)
    }

    func setupFavoritesRealmNotificationToken() {
        favoritesRealmNotificationToken = favoriteBillsInRealm?.observe { [weak self] (_)->Void in
            if (self?.isAuthorized)! {
                self?.updateFirebaseFavoriteRecords()
            }
        }
    }

    func setupFavoritesHangle() {
        guard let userId = uid else { return }
        let refHandle = dbLink.child(userId).child("favoriteBills").observe(DataEventType.value, with: { (snapshot) in
            let favoriteBillsInFirebase = snapshot.value as? [String : Double] ?? [:]
            for item in favoriteBillsInFirebase {
                let billNumber = item.key
                let serverTimestamp = item.value
                if let existingBill = self.realm?.object(ofType: Bill_.self, forPrimaryKey: billNumber) {

                    // need to update server record :
                    if existingBill.favoriteUpdatedTimestamp > serverTimestamp {
                        if existingBill.favorite {
                            // adding new favorite to the server
                            self.dbLink.child(userId).child("favoriteBills").setValue([existingBill.number : existingBill.favoriteUpdatedTimestamp])
                        } else {
                            // removing a favorite from the server
                            self.dbLink.child(userId).child("favoriteBills").child(existingBill.number).removeValue()
                        }

                    // need to update local record :
                    } else if existingBill.favoriteUpdatedTimestamp < serverTimestamp {
                        try? self.realm?.write {
                            existingBill.favorite = true
                            existingBill.favoriteUpdatedTimestamp = serverTimestamp
                        }
                    }

                    // else: timestamps are equal, nothing to update
                    // (...)

                } else { // Need to create and load a non-existing bill
                    UserServices.downloadNonExistingBillBySync(withNumber: billNumber, favoriteTimestamp: serverTimestamp)
                }
            }
        })
    }


}
