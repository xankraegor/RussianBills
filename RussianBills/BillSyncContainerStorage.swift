//
//  BillSyncContainerStorage.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
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


}
