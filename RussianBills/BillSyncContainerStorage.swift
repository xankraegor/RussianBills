//
//  BillSyncContainerStorage.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import CloudKit
import RealmSwift

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

    public var allBills: [SyncProxy] {
        return realm.objects(FavoriteBill_.self).sorted(byKeyPath: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false).map{$0.syncProxy}
    }

    var mostRecentlyModifiedBillSyncContainer: SyncProxy? {
        let realmBillsByFavoriteUpdatedTimestamp = realm.objects(FavoriteBill_.self)
            .sorted(byKeyPath: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false)

        return realmBillsByFavoriteUpdatedTimestamp.first?.syncProxy
    }

    public func store(billSyncContainer: SyncProxy) throws {
        try store(favoriteBill: billSyncContainer.favoriteBill)
    }

    func store(favoriteBill: FavoriteBill_, notNotifying token: NotificationToken? = nil) throws {
        try insertOrUpdate(object: favoriteBill, notNotifying: token) { oldBill, newBill in

            guard newBill != oldBill else {
                return false
            }

            return newBill.favoriteUpdatedTimestamp > oldBill.favoriteUpdatedTimestamp
        }
    }

    private func insertOrUpdate<T: Object>(objects: [T],notNotifying token: NotificationToken? = nil, updateDecisionHandler: @escaping UpdateDecisionHandler<T>) throws {
        try objects.forEach{ try self.insertOrUpdate(object: $0, notNotifying: token, updateDecisionHandler: updateDecisionHandler) }
    }

    private func insertOrUpdate<T: Object>(object: T, notNotifying token: NotificationToken? = nil, updateDecisionHandler: @escaping UpdateDecisionHandler<T>) throws {
        guard let primaryKey = T.primaryKey(),
            let primaryKeyValue = object.value(forKey: primaryKey) else {
                fatalError("insertOrUpdate can't be used for objects without a primary key")
        }

        slog("Container:insertOrUpdate")

        let tokens: [NotificationToken]

        if let token = token {
            tokens = [token]
        } else {
            tokens = []
        }

        if let existingObject = realm.object(ofType: T.self, forPrimaryKey: primaryKeyValue) {
            slog("Container:insertOrUpdate an object already exists")
            // object already exists, call updateDecisionHandler to determine whether we should update it or not
            if updateDecisionHandler(existingObject, object) {
                realm.beginWrite()
                realm.add(object, update: true)
                slog("Container:insertOrUpdate an object already exists, updated in realm")
                try realm.commitWrite(withoutNotifying: tokens)
            }
        } else {
            // object doesn't exist, just add it
            realm.beginWrite()
            realm.add(object)
            try realm.commitWrite(withoutNotifying: tokens)
            slog("Container:insertOrUpdate added an object missing in realm")
        }
    }

    public func removeFromFavorites(with number: String, hard reallyRemove: Bool = false) throws {
        guard let favoriteBill = realm.object(ofType: FavoriteBill_.self, forPrimaryKey: number) else {
            throw StorageError.recordNotFound(number)
        }

        try realm.write {
            if reallyRemove {
                slog("FavoriteBill \(favoriteBill.number) removed from realm)")
                self.realm.delete(favoriteBill)
            } else {
                favoriteBill.markedToBeRemovedFromFavorites = true
                realm.add(favoriteBill, update: true)
                slog("FavoriteBill \(favoriteBill.number) marked for removal)")
            }
        }
    }

    func deletePreviouslyUnfavoritedBills(notNotifying token: NotificationToken? = nil) throws {
        slog("deletePreviouslyUnfavoritedBills:notNotifying:")
        let objects = realm.objects(FavoriteBill_.self).filter("markedToBeRemovedFromFavorites == true")

        if let token = token {
            realm.beginWrite()
            objects.forEach{ realm.delete($0) }
            try realm.commitWrite(withoutNotifying: [token])
        } else {
            realm.beginWrite()
            objects.forEach{ realm.delete($0) }
            try realm.commitWrite()
        }
    }

}
