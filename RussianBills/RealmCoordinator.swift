//
//  RealmCoordinator.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

public enum RealmCoordinatorListType: String {
    case quickSearchList
    case mainSearchList
}

enum RealmCoordinator {

    static func loadObjectsWithFilter <T>(ofType: T.Type, applyingFilter filterString: String? = nil) -> Results<T>? where T: Object, T: QuickSearchFieldsReporting {
        do {
            let realm = try Realm()

            // Case 1: no filters, return all objects
            guard let existingFilterString = filterString, existingFilterString.count > 0 else {
                return realm.objects(T.self)
            }

            // Case 2: Object has only one field capable of filtering by
            let searchFieldsCount = T.searchFields.count
            let baseFilterPredicate = NSPredicate(format: "\(T.searchFields[0]) CONTAINS[cd] '\(existingFilterString)'")
            guard searchFieldsCount > 1 else {
                return realm.objects(T.self).filter(baseFilterPredicate)
            }

            // Case 3: Many filtering fields, compound predicate needed
            var groupOfPredicates: Array<NSPredicate> = [baseFilterPredicate]
            for i in 1...searchFieldsCount-1 {
                let otherPredicate = NSPredicate(format: "\(T.searchFields[i]) CONTAINS[cd] '\(existingFilterString)'")
                groupOfPredicates.append(otherPredicate)
            }

            let cumulativePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: groupOfPredicates)
            return realm.objects(T.self).filter(cumulativePredicate)
        } catch let error {
            fatalError("∆ Cannot load filtered objects by reason: \(error)")
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
    
    static func setBillsList(ofType type: RealmCoordinatorListType, toContain bills: [Bill_]?) {
        do {
            let realm = try Realm()
            try realm.write {
                let newList = BillsList_()
                newList.name = type.rawValue
                if let billsNoNil = bills {
                    newList.bills.append(objectsIn: billsNoNil)
                }
                realm.add(newList, update: true)
            }
        } catch let error {
            fatalError("∆ Cannot set \(type.rawValue) bills list: \(error)")
        }
    }
    
}
