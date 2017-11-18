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

    func loadFilteredObjects <T>(_ ofType: T.Type, orString: String? = nil, andCurrent: Bool? = nil, dumaDeps: Bool? = nil) -> Results<T>? where T: Object, T: QuickSearchFieldsReporting {

        var prdicatesOr: [NSPredicate] = []
        var predicatesAnd: [NSPredicate] = []

        if let existingFilterString = orString, existingFilterString.count > 0 {
            prdicatesOr.append(contentsOf: T.searchFields.map{NSPredicate(format: "\($0) CONTAINS[cd] '\(existingFilterString)'")})
        }

        if let current = andCurrent {
            predicatesAnd.append(NSPredicate(format: "isCurrent = \(current)"))
        }

        if let deps = dumaDeps { // true - dumaDeps, false - councilMems
            let predicate = NSPredicate(format: "position CONTAINS[cd] '\(deps ? "депутат" : "член")'")
            predicatesAnd.append(predicate)
        }

        let strPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: prdicatesOr)
        predicatesAnd.append(strPredicate)
        return self.objects(T.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicatesAnd))

    }
    
}
