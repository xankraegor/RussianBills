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

    static let suiteName = "group.com.xankraegor.russianBills"

    /// 24 hrs in seconds
    static let referenceValuesUpdateTimeout: TimeInterval = 86400
    /// 30 min in seconds
    static let defaultBillsUpdateTimeout: TimeInterval = 300

    // MARK: - Public methods

    /// Checks, if reference values of selected self type were updated prior to (now - referenceValuesUpdateTimeout)
    public func updateRequired() -> Bool {
        let key = variableNameForUpdateTimestamp()

        guard let updatedDate = updatedAt(),
            let previousUpdateTimestamp = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.double(forKey: key) as Double?, previousUpdateTimestamp > 0 else {
            return true
        }

        let timeout: TimeInterval
        switch self {
        case .favorites:
            timeout =  UserDefaultsCoordinator.favoriteBillsUpdateTimeout()
        default:
            timeout = UserDefaultsCoordinator.referenceValuesUpdateTimeout
        }

        let nextUpdateDate = Date(timeIntervalSince1970: previousUpdateTimestamp).addingTimeInterval(timeout)

        return nextUpdateDate < updatedDate
    }

    public func updatedAt() -> Date? {
        let key = variableNameForUpdateTimestamp()
        guard let timestamp = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.double(forKey: key) as Double? else { return nil }

        let date = Date(timeIntervalSince1970: timestamp)
        let reference = Date(timeIntervalSinceReferenceDate: 0)

        if date < reference {
            return nil
        } else {
            return date
        }
    } 

    public static func updateTimestampUsingClassType(ofCollection: [Object]) {
        guard let element = ofCollection.first else {
            return
        }

        if element is FavoriteBill_ {
            UserDefaultsCoordinator.favorites.updateTimestamp()
            return
        }

        #if BASEPROJECT
            switch element {
            case _ as FederalSubject_:
                UserDefaultsCoordinator.federalSubject.updateTimestamp()
            case _ as RegionalSubject_ :
                UserDefaultsCoordinator.regionalSubject.updateTimestamp()
            case _ as Committee_:
                UserDefaultsCoordinator.committee.updateTimestamp()
            case _ as LawClass_:
                UserDefaultsCoordinator.lawClass.updateTimestamp()
            case _ as Deputy_:
                UserDefaultsCoordinator.deputy.updateTimestamp()
            case _ as Topic_:
                UserDefaultsCoordinator.topics.updateTimestamp()
            case _ as Instance_:
                UserDefaultsCoordinator.instances.updateTimestamp()
            case _ as Stage_:
                UserDefaultsCoordinator.stage.updateTimestamp()
            default: break
            }
        #endif

    }
    
    public static func saveQuickSearchFields(name: String, nr1: String, nr2: String) {
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(name, forKey: "quickSearchSavedName")
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(nr1, forKey: "quickSearchSavedNr1")
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(nr2, forKey: "quickSearchSavedNr2")
    }
    
    public static func getQuickSearchFields()->(name: String?, nr1: String?, nr2: String?) {
        let name = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.string(forKey: "quickSearchSavedName")
        let nr1 = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.string(forKey: "quickSearchSavedNr1")
        let nr2 = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.string(forKey: "quickSearchSavedNr2")
        return (name, nr1, nr2)
    }

    public static func favoriteBillsUpdateTimeout()->Double {
        let storedUpdateTimeout = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.double(forKey: "favoriteUpdateTimeout")
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
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(Date().timeIntervalSince1970, forKey: key)
    }

}
