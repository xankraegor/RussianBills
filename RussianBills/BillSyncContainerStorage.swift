//
//  BillSyncContainerStorage.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

enum StorageError: Error {
    case recordNotFound(String)

    var localizedDescription: String {
        switch self {
        case .recordNotFound(let identifier):
            return "Record not found with primary key \(identifier)"
        }
    }
}

/// This class is responsible for the management of the local database (fetching, saving and deleting notes)
public final class BillSyncContainerStorage {
    typealias UpdateDecisionHandler<T> = (_ oldObject: T, _ newObject: T) -> Bool

    let realm: Realm

    init(realm: Realm? = nil) {
        if let r = realm {
            self.realm = r
        } else {
            self.realm = try! Realm()
        }
    }

    public convenience init() {
        self.init(realm: nil)
    }

    public var allBills: Observable<[BillSyncContainer]> {
        let objects = self.realm.objects(Bill_.self)
            .filter(NSPredicate(format: "favorite == true"))
        //            .sorted(byKeyPath: "modifiedAt", ascending: false)

        return Observable.collection(from: objects).map { realmBills in
            return realmBills.map({ $0.billSyncContainer })
        }
    }

    var mostRecentlyModifiedBillSyncContainer: BillSyncContainer? {
        let realmBillsByFavoriteUpdatedTimestamp = realm.objects(Bill_.self)
            .sorted(byKeyPath: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false)
        //        let realmBillsByHasUnseenChangesUpdatedTimestamp = realm.objects(Bill_.self)
        //            .sorted(byKeyPath: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false)
        //        let maxFavUpdTs = realmBillsByFavoriteUpdatedTimestamp.first?.favoriteUpdatedTimestamp ?? Date.distantPast
        //        let maxHasUnsChTs = realmBillsByHasUnseenChangesUpdatedTimestamp.first?.favoriteHasUnseenChangesTimestamp ?? Date.distantPast
        //        if maxFavUpdTs >= maxHasUnsChTs {
        return realmBillsByFavoriteUpdatedTimestamp.first?.billSyncContainer
        //        } else {
        //            return realmBillsByHasUnseenChangesUpdatedTimestamp.first?.billSyncContainer
        //        }
    }

    public func store(billSyncContrainer: BillSyncContainer) throws {
        try store(bill: billSyncContrainer.bill)
    }

    func store(bill: Bill_, notNotifying token: NotificationToken? = nil) throws {
        try insertOrUpdate(object: bill, notNotifying: token) { oldBill, newBill in

            guard newBill != oldBill else {
                return false
            }

            return newBill.favoriteUpdatedTimestamp > oldBill.favoriteUpdatedTimestamp
        }
    }

    private func insertOrUpdate<T: Object>(objects: [T],
                                           notNotifying token: NotificationToken? = nil,
                                           updateDecisionHandler: @escaping UpdateDecisionHandler<T>) throws {
        try objects.forEach({ try self.insertOrUpdate(object: $0, notNotifying: token, updateDecisionHandler: updateDecisionHandler) })
    }

    private func insertOrUpdate<T: Object>(object: T,
                                           notNotifying token: NotificationToken? = nil,
                                           updateDecisionHandler: @escaping UpdateDecisionHandler<T>) throws {
        guard let primaryKey = T.primaryKey() else {
            fatalError("insertOrUpdate can't be used for objects without a primary key")
        }

        guard let primaryKeyValue = object.value(forKey: primaryKey) else {
            fatalError("insertOrUpdate can't be used for objects without a primary key")
        }

        let tokens: [NotificationToken]

        if let token = token {
            tokens = [token]
        } else {
            tokens = []
        }

        if let existingObject = realm.object(ofType: T.self, forPrimaryKey: primaryKeyValue) {
            // object already exists, call updateDecisionHandler to determine whether we should update it or not
            if updateDecisionHandler(existingObject, object) {
                realm.beginWrite()
                realm.add(object, update: true)
                try realm.commitWrite(withoutNotifying: tokens)
            }
        } else {
            // object doesn't exist, just add it
            realm.beginWrite()
            realm.add(object)
            try realm.commitWrite(withoutNotifying: tokens)
        }
    }

    public func removeFromFavorites(with number: String, hard reallyRemove: Bool = false) throws {
        guard let bill = realm.object(ofType: Bill_.self, forPrimaryKey: number) else {
            throw StorageError.recordNotFound(number)
        }

        try realm.write {
            if reallyRemove {
                bill.favorite = false
                bill.favoriteUpdatedTimestamp = Date.distantPast
                bill.favoriteHasUnseenChanges = false
//                bill.favoriteHasUnseenChangesTimestamp = Date.distantPast
                self.realm.add(bill, update: true)
            } else {
                bill.markedToBeRemovedFromFavorites = true
                self.realm.add(bill, update: true)
            }
        }
    }

        func deletePreviouslyUnfavoritedBills(notNotifying token: NotificationToken? = nil) throws {
            let objects = realm.objects(Bill_.self).filter("favorite = false")

            let tokens: [NotificationToken]
            if let token = token {
                tokens = [token]
            } else {
                tokens = []
            }

            realm.beginWrite()
            objects.forEach({ realm.delete($0) })
            try realm.commitWrite(withoutNotifying: tokens)
        }

}
