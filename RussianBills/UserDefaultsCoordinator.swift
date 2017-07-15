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

    // TODO:- Stage implementation
    case stage

    /// 24 hrs in seconds
    static let referenceValuesUpdateTimeout: TimeInterval = 86400

    // MARK: - Public methods

    /// Checks, if reference values of selected self type were updated prior to (now - defaultReferenceValuesUpdateTimeout)
    public func referenceValuesUpdateRequired() -> Bool {
        let key = variableNameForUpdateTimeout()
        guard let previousUpdateTimestamp = UserDefaults.standard.double(forKey: key) as Double?, previousUpdateTimestamp > 0 else {
            debugPrint("UserDefaultsCoordinator: \(self.variableNameForUpdateTimeout()) requires to be updated, because there's no timestamp")
            return true
        }

        let now = Date()
        let updateNeeded = previousUpdateTimestamp + UserDefaultsCoordinator.referenceValuesUpdateTimeout < now.timeIntervalSinceReferenceDate
        debugPrint("UserDefaultsCoordinator: \(self.variableNameForUpdateTimeout()) \(!updateNeeded ? "does not have to be updated" : "requires update"), timestamp \(previousUpdateTimestamp)")
        return updateNeeded
    }

    public static func updateReferenceValuesTimestampUsingClassType(ofCollection: [Object]) {
        guard ofCollection.count > 0 else {
            return
        }

        if ofCollection.first is FederalSubject_ {
            UserDefaultsCoordinator.federalSubject.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is RegionalSubject_ {
            UserDefaultsCoordinator.regionalSubject.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is Comittee_ {
            UserDefaultsCoordinator.committee.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is LawClass_ {
            UserDefaultsCoordinator.lawClass.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is Deputy_ {
            UserDefaultsCoordinator.deputy.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is Topic_ {
            UserDefaultsCoordinator.topics.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is Instance_ {
            UserDefaultsCoordinator.instances.updateReferanceValuesTimestamp()
            return
        }

        if ofCollection.first is Stage_ {
            UserDefaultsCoordinator.stage.updateReferanceValuesTimestamp()
            return
        }

    }

    public static func DEBUG_printUserDefaults() {
        debugPrint("USER DEFAULTS CONTENTS")
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            debugPrint("\(key) = \(value) \n")
        }
    }

    // MARK: - Private methods

    /// Returns variable name in UserDefaults to hold last updated timestamp
    /// i.g. lawClassUpdateTimeout
    private func variableNameForUpdateTimeout() -> String {
        return self.rawValue + "UpdateTimeout"
    }

    private func updateReferanceValuesTimestamp() {
        let key = variableNameForUpdateTimeout()
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: key)
    }

}
