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

    func loadFilteredObjects <T>(_ ofType: T.Type, orString: String? = nil, andCurrent: Bool? = nil ) -> Results<T>? where T: Object, T: QuickSearchFieldsReporting {

        var predicatesString: [NSPredicate] = []
        var predicatesBool: [NSPredicate] = []

        if let existingFilterString = orString, existingFilterString.count > 0 {
            predicatesString.append(contentsOf: T.searchFields.map{NSPredicate(format: "\($0) CONTAINS[cd] '\(existingFilterString)'")})
        }

        if let current = andCurrent {
            predicatesBool.append(NSPredicate(format: "isCurrent = \(current)"))
        }

        if predicatesString.count > 0 && predicatesBool.count == 0 {
            return self.objects(T.self).filter(NSCompoundPredicate(orPredicateWithSubpredicates: predicatesString))
        }

        if predicatesString.count == 0 && predicatesBool.count > 0 {
            return self.objects(T.self).filter(predicatesBool[0])
        }

        if predicatesString.count > 0 && predicatesBool.count > 0 {
            let strPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicatesString)
            let predicates = [strPredicate, predicatesBool[0]]
            return self.objects(T.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        }

        return self.objects(T.self)
    }
    
}
