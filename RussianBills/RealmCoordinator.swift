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

    static func DEBUG_defaultRealmPath() -> String {
        return "Default realm path: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))"
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

    static func save(object: Object) {

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: true)
            }
        } catch let error {
            fatalError("∆ Cannot reach the Realm to save object: \(error.localizedDescription)")
        }
    }

    static func updateFavoriteStatusOf(bill: Bill_, to isFavourite: Bool, completion: (()->Void)? = nil) {
        do {
            let realm = try Realm()
            let updBill = bill
            try realm.write {
                updBill.favorite = isFavourite
                realm.add(updBill, update: true)
            }
            if completion != nil {
                completion!()
            }
        } catch let error {
            fatalError("∆ Cannot reach the Realm to update favorite status for a bill: \(error.localizedDescription)")
        }
    }

    // MARK: Load data from Realm

    static func loadObjects<T: Object>(_ ofType: T.Type) -> Results<T>? {
        do {
            let realm = try Realm()
            return realm.objects(T.self)
        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    static func loadObjectsWithFilter <T>(ofType: T.Type, applyingFilter filterString: String? = nil) -> Results<T>? where T: Object, T: QuickSearchFieldsReporting {
        do {
            let realm = try Realm()

            // Case 1: no filters, return all objects
            guard let existingFilterString = filterString, existingFilterString.count > 0 else {
                return realm.objects(T.self)
            }

            // Case 2: Object has only one field capable of filtering by
            let objectsOfType = realm.objects(T.self)

            let searchFieldsCount = T.searchFields.count
            print("∆ Existing filter string: \(existingFilterString)")

            let baseFilterPredicate = NSPredicate(format: "\(T.searchFields[0]) CONTAINS[cd] '\(existingFilterString)'")

            guard searchFieldsCount > 1 else {
                print("∆ PREDICATE DESCRIPTION: " + baseFilterPredicate.description)
                return objectsOfType.filter(baseFilterPredicate)
            }

            // Case 3: Many filtering fields, compound predicate needed

            var groupOfPredicates: Array<NSPredicate> = [baseFilterPredicate]

            for i in 1...searchFieldsCount-1 {
                let otherPredicate = NSPredicate(format: "\(T.searchFields[0]) CONTAINS[cd] '\(existingFilterString)'")
                groupOfPredicates.append(otherPredicate)
            }

            let cumulativePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: groupOfPredicates)
            print("∆ CUMULATIVE PREDICATE DESCRIPTION: " + cumulativePredicate.description)

            return objectsOfType.filter(cumulativePredicate)

        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    static func loadObject<T: Object>(_ ofType: T.Type, sortedBy sortParameter: String, ascending: Bool, byIndex: Int) -> T {
        do {
            let realm = try Realm()
            let objs = realm.objects(T.self).sorted(byKeyPath: sortParameter, ascending: ascending)
            return objs[byIndex]
        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    static func loadObject<T: Object>(_ ofType: T.Type, byId id: Int) -> T? {
        do {
            let realm = try Realm()
            let objs = realm.objects(T.self).filter("id == \(id)")
            return objs.first
        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    static func loadBills(matchingQuery query: BillSearchQuery, sortedBy sortParameter: String, sortDirection ascending: Bool) -> [Bill_] {
        do {
            let realm = try Realm()
            var objects = realm.objects(Bill_.self)
            // TODO: Full mirroring
            if let name = query.name {
                objects = objects.filter("name contains '\(name)'")
            }
            if let number = query.number {
                objects = objects.filter("number contains '\(number)'")
            }

            return Array(objects)
        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    static func loadFavoriteBills() -> Results<Bill_> {
        do {
            let realm = try Realm()
            let objs = realm.objects(Bill_.self)
            return objs.filter("favorite == true")
        } catch let error {
            fatalError("∆ Cannot reach the Realm to load objects: Realm is not initialized by the Realm coordinator: \(error)")
        }

    }
    
    static func getFavoriteStatusOf(billNr: String)->Bool? {
        do {
            let realm = try Realm()
            return (realm.object(ofType: Bill_.self, forPrimaryKey: billNr))?.favorite
        } catch let error {
            fatalError("∆ Cannot reach the Realm to get favorite status for a bill: \(error.localizedDescription)")
        }
    }


    // MARK: - Count data in Realm

    static func countObjects(ofType type: Object.Type) -> Int {
        do {
            let realm = try Realm()
            return realm.objects(type).count
        } catch let error {
            fatalError("∆ Cannot reach the Realm to count objects: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    static func countBills(matchingQuery: BillSearchQuery) -> Int {
        do {
            let realm = try Realm()
            var objects = realm.objects(Bill_.self)
            if let name = matchingQuery.name {
                objects = objects.filter("name contains '\(name)'")
            }
            if let number = matchingQuery.number {
                objects = objects.filter("number contains '\(number)'")
            }
            return objects.count
        } catch let error {
            fatalError("∆ Cannot reach the Realm to count bills matching query: Realm is not initialized by the Realm coordinator: \(error)")
        }
    }

    // MARK: - Delete data from realm

    static func deleteEverything() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error {
            fatalError("∆ Cannot clear caches: \(error)")
        }
    }
    
    // MARK: - Managing Lists
    
    static func getQuickSearchBillsList()->BillsList_ {
        do {
            let realm = try Realm()
            if let list = realm.object(ofType: BillsList_.self, forPrimaryKey: "quickSearchList") {
                return list
            } else {
                let newList = BillsList_()
                newList.name = "quickSearchList"
                try realm.write {
                    realm.add(newList, update: true)
                }
                return newList
            }
        } catch let error {
            fatalError("∆ Cannot get quick search bills list: \(error)")
        }
    }

    static func getQuickSearchBillsListItems()->[Bill_] {
        do {
            let realm = try Realm()
            if let list = realm.object(ofType: BillsList_.self, forPrimaryKey: "quickSearchList")?.bills {
                return Array(list)
            } else {
                return []
            }
        } catch let error {
            fatalError("∆ Cannot get quick search bills list items: \(error)")
        }
    }
    
    static func setQuickSearchBillsList(toContain bills: [Bill_]?) {
        do {
            let realm = try Realm()
            try realm.write {
                let newList = BillsList_()
                newList.name = "quickSearchList"
                if let billsNoNil = bills {
                    newList.bills.append(objectsIn: billsNoNil)
                }
                realm.add(newList, update: true)
            }
        } catch let error {
            fatalError("∆ Cannot set quick search bills list: \(error)")
        }
    }
    
}
