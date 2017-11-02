//
//  RealmCoordinator.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {

    static func loadObjectsWithFilter <T>(ofType: T.Type, applyingFilter filterString: String? = nil) -> Results<T>? where T: Object, T: QuickSearchFieldsReporting {
        do {
            let realm = try Realm()
            guard let existingFilterString = filterString, existingFilterString.count > 0 else {
                return realm.objects(T.self)
            }
            let predicates = T.searchFields.map{NSPredicate(format: "\($0) CONTAINS[cd] '\(existingFilterString)'")}
            return realm.objects(T.self).filter(NSCompoundPredicate(orPredicateWithSubpredicates: predicates))
        } catch let error {
            fatalError("∆ Cannot load filtered objects by reason: \(error)")
        }
    }
}
