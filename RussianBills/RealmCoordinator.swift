//
//  RealmCoordinator.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmCoordinator {

    // MARK: Write and update existing data in Realm

    static func save(collection: [Object]) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(collection, update: true)
            }
        } catch let error {
            fatalError("∆ Cannot reach the Realm to save objects: \(error.localizedDescription)")
        }
    }

    // MARK: Load data from Realm

    static func load<T: Object>(forObjects: T.Type) -> Results<T>? {
        do {
            let realm = try Realm()
            return realm.objects(T.self)
        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: \(error.localizedDescription)")
        }
    }

    // MARK: Delete data from realm

    static func deleteEverything() {
        guard let realm = try? Realm() else {
            fatalError("∆ Cannot reach the Realm to clear caches")
        }

        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch let error {
            fatalError("∆ Cannot reach the Realm to clear caches: \(error.localizedDescription)")
        }
    }

}
