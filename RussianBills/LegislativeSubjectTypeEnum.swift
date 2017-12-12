//
//  LegislativeSubjectTypeEnum.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

enum LegislativeSubjectType {
    case federalSubject
    case regionalSubject
    case deputy

    private func objectType()->Object.Type {
        switch self {
        case .federalSubject:
            return FederalSubject_.self
        case .regionalSubject:
            return RegionalSubject_.self
        case .deputy:
            return Deputy_.self
        }
    }

    func item(byId id: Int) -> Object? {
        if let realm = try? Realm() {
            return realm.object(ofType: objectType(), forPrimaryKey: id)
        }

        return nil
    }
}
