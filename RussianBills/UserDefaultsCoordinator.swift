//
//  UserDefaultsCoordinator.swift
//  RussianBills
//
//  Created by Xan Kraegor on 11.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

enum UserDefaultsCoordinator: String {

    case federalSubject
    case regionalSubject
    case committee
    case lawClass
    case deputy
    case topics
    case instances
    case stage
    case favorites

    /// 24 hrs in seconds
    static let referenceValuesUpdateTimeout: TimeInterval = 86400
    /// 30 min in seconds
    static let defaultBillsUpdateTimeout: TimeInterval = 300

    // MARK: - Public methods

    /// Checks, if reference values of selected self type were updated prior to (now - referenceValuesUpdateTimeout)
    public func updateRequired() -> Bool {
        switch self {

        case .favorites:
            guard let previousUpdateTimestamp = UserDefaults.standard.double(forKey: "favoritesUpdateTimestamp") as Double?, previousUpdateTimestamp > 0 else {
                return true
            }

            return previousUpdateTimestamp + UserDefaultsCoordinator.favoriteBillsUpdateTimeout() < Date().timeIntervalSince1970

        default:
            let key = variableNameForUpdateTimestamp()
            guard let previousUpdateTimestamp = UserDefaults.standard.double(forKey: key) as Double?, previousUpdateTimestamp > 0 else {
                return true
            }

            return previousUpdateTimestamp + UserDefaultsCoordinator.referenceValuesUpdateTimeout < Date().timeIntervalSince1970
        }
    }

    public static func updateTimestampUsingClassType(ofCollection: [Object]) {
        guard ofCollection.count > 0 else {
            return
        }

        if ofCollection.first is FavoriteBill_ {
            UserDefaultsCoordinator.favorites.updateTimestamp()
        }

        if ofCollection.first is FederalSubject_ {
            UserDefaultsCoordinator.federalSubject.updateTimestamp()
            return
        }

        if ofCollection.first is RegionalSubject_ {
            UserDefaultsCoordinator.regionalSubject.updateTimestamp()
            return
        }

        if ofCollection.first is Committee_ {
            UserDefaultsCoordinator.committee.updateTimestamp()
            return
        }

        if ofCollection.first is LawClass_ {
            UserDefaultsCoordinator.lawClass.updateTimestamp()
            return
        }

        if ofCollection.first is Deputy_ {
            UserDefaultsCoordinator.deputy.updateTimestamp()
            return
        }

        if ofCollection.first is Topic_ {
            UserDefaultsCoordinator.topics.updateTimestamp()
            return
        }

        if ofCollection.first is Instance_ {
            UserDefaultsCoordinator.instances.updateTimestamp()
            return
        }

        if ofCollection.first is Stage_ {
            UserDefaultsCoordinator.stage.updateTimestamp()
            return
        }

    }
    
    public static func saveQuickSearchFields(name: String, nr1: String, nr2: String) {
        UserDefaults.standard.set(name, forKey: "quickSearchSavedName")
        UserDefaults.standard.set(nr1, forKey: "quickSearchSavedNr1")
        UserDefaults.standard.set(nr2, forKey: "quickSearchSavedNr2")
    }
    
    public static func getQuickSearchFields()->(name: String?, nr1: String?, nr2: String?) {
        let name = UserDefaults.standard.string(forKey: "quickSearchSavedName")
        let nr1 = UserDefaults.standard.string(forKey: "quickSearchSavedNr1")
        let nr2 = UserDefaults.standard.string(forKey: "quickSearchSavedNr2")
        return (name, nr1, nr2)
    }

    public static func favoriteBillsUpdateTimeout()->Double {
        let storedUpdateTimeout = UserDefaults.standard.double(forKey: "favoriteUpdateTimeout")
        let favoritesUpdateTimeout = storedUpdateTimeout == 0 ? UserDefaultsCoordinator.defaultBillsUpdateTimeout : storedUpdateTimeout
        return favoritesUpdateTimeout
    }

    // MARK: - Private methods

    /// Returns variable name in UserDefaults to hold last updated timestamp
    /// i.g. lawClassUpdateTimeout
    private func variableNameForUpdateTimestamp() -> String {
        return self.rawValue + "UpdateTimestamp"
    }

    private func updateTimestamp() {
        let key = variableNameForUpdateTimestamp()
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
    }

}
