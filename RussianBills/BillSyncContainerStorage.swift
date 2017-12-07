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
        let objects = self.realm.objects(FavoriteBill_.self)
            .sorted(byKeyPath: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false)

        return Observable.collection(from: objects).map {
            realmBills in
            return realmBills.map({ $0.billSyncContainer })
        }
    }

    var mostRecentlyModifiedBillSyncContainer: BillSyncContainer? {
        let realmBillsByFavoriteUpdatedTimestamp = realm.objects(FavoriteBill_.self)
            .sorted(byKeyPath: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false)

        return realmBillsByFavoriteUpdatedTimestamp.first?.billSyncContainer
    }

    public func store(billSyncContainer: BillSyncContainer) throws {
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
        guard let favoriteBill = realm.object(ofType: FavoriteBill_.self, forPrimaryKey: number) else {
            throw StorageError.recordNotFound(number)
        }

        try realm.write {
            if reallyRemove {
                self.realm.delete(favoriteBill)
            } else {
                favoriteBill.markedToBeRemovedFromFavorites = true
                realm.add(favoriteBill, update: true)
            }
        }
    }

    func deletePreviouslyUnfavoritedBills(notNotifying token: NotificationToken? = nil) throws {
        let objects = realm.objects(FavoriteBill_.self).filter("markedToBeRemovedFromFavorites == true")

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
