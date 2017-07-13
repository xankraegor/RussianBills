//
//  RealmCoordinator.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCoordinator {

    static func defaultRealmPath() -> String {
        return String(describing: Realm.Configuration.defaultConfiguration.fileURL)
    }

    // MARK: Write and update existing data in Realm

    static func save(collection: [Object]) {
        
        do {
            let realm = try Realm()
            try realm.write {
                for obj in collection {
                    realm.add(obj, update: true)
                }
            }
            
            UserDefaultsCoordinator.updateReferenceValuesTimestampUsingClassType(ofCollection: collection)
            
        } catch let error {
            fatalError("∆ Cannot reach the Realm to save objects: \(error.localizedDescription)")
        }
    }

    static func updateFavoriteStatusOf(bill: Bill_, to isFavourite: Bool) {
        do {
            let realm = try Realm()
            let updBill = bill
            try realm.write {
                updBill.favorite = isFavourite
                realm.add(updBill, update: true)
            }
        } catch let error {
            fatalError("∆ Cannot reach the Realm to update favorite status for a bill: \(error.localizedDescription)")
        }
        
    }

    // MARK: Load data from Realm

    static func loadObjects<T: Object>(OfType: T.Type) -> Results<T>? {
        let realm = try? Realm()
        if let rlm = realm {
            return rlm.objects(T.self)
        } else {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinater")
        }
    }
    
    
    static func loadObject<T: Object>(ofType: T.Type, sortedBy sortParameter: String, ascending: Bool, byIndex: Int) -> T {
        let realm = try? Realm()
        if let rlm = realm {
            let objs = rlm.objects(T.self).sorted(byKeyPath: sortParameter, ascending: ascending)
            return objs[byIndex]
        } else {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinater")
        }
    }
    
    static func loadBills(matchingQuery: BillSearchQuery, sortedBy sortParameter: String, ascending: Bool) -> [Bill_] {
        let realm = try? Realm()
        if let rlm = realm {
            var objects = rlm.objects(Bill_.self)
            // TODO: Full mirroring
            if let name = matchingQuery.name {
                objects = objects.filter("name contains '\(name)'")
            }
            if let number = matchingQuery.number {
                objects = objects.filter("number contains '\(number)'")
            }

            return Array(objects)
        } else {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinater")
        }
    }

    
    // MARK:- Count data in Realm

    static func countObjects(ofType type: Object.Type) -> Int {
        let realm = try? Realm()
        if let rlm = realm {
            return rlm.objects(type).count
        } else {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinater")
        }
    }
    
    static func countBills(matchingQuery: BillSearchQuery) -> Int {
        let realm = try? Realm()
        if let rlm = realm {
            var objects = rlm.objects(Bill_.self)
            if let name = matchingQuery.name {
                objects = objects.filter("name contains '\(name)'")
            }
            if let number = matchingQuery.number {
                objects = objects.filter("number contains '\(number)'")
            }
            return objects.count
        } else {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinater")
        }
    }


    // MARK: - Delete data from realm

    static func deleteEverything() {
        let realm = try? Realm()
        if let rlm = realm {
            do {
                try rlm.write {
                    rlm.deleteAll()
                }
            } catch let error {
                fatalError("∆ Cannot reach the Realm to clear caches: \(error.localizedDescription)")
            }
        } else {
            fatalError("∆ Cannot reach the Realm to clear caches: Realm is not initialized by the Realm coordinater")
        }

    }

    

}
