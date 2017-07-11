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
    
    // MARK:- Public methods
    
    /// Checks, if reference values of selected self type were updated prior to (now - defaultReferenceValuesUpdateTimeout)
    public func referenceValuesUpdateRequired()->Bool {
        let key = variableNameForUpdateTimeout()
        if let previousUpdateTimestamp = UserDefaults.standard.double(forKey: key) as Double? {
            return previousUpdateTimestamp + UserDefaultsCoordinator.referenceValuesUpdateTimeout < Date().timeIntervalSinceReferenceDate
        } else {
            return true
        }
    }
    
    

    public static func updateReferenceValuesTimestampUsingClassType<T>(ofCollection: [T]) where T: Object {
        
        switch T.className() {
        case FederalSubject_.className():
            UserDefaultsCoordinator.federalSubject.updateReferanceValuesTimestamp()
        case RegionalSubject_.className():
            UserDefaultsCoordinator.regionalSubject.updateReferanceValuesTimestamp()
        case Comittee_.className():
            UserDefaultsCoordinator.committee.updateReferanceValuesTimestamp()
        case LawClass_.className():
            UserDefaultsCoordinator.lawClass.updateReferanceValuesTimestamp()
        case Deputy_.className():
            UserDefaultsCoordinator.deputy.updateReferanceValuesTimestamp()
        case Topic_.className():
            UserDefaultsCoordinator.topics.updateReferanceValuesTimestamp()
        case Instance_.className():
            UserDefaultsCoordinator.instances.updateReferanceValuesTimestamp()
// TODO:- Stage implementation
//        case Stage_.className():
//            UserDefaultsCoordinator.stage.updateReferanceValuesTimestamp()
        default:
            return
        }
    }
    
    // MARK:- Private methods
    
    /// Returns variable name in UserDefaults to hold last updated timestamp
    /// i.g. lawClassUpdateTimeout
    private func variableNameForUpdateTimeout()->String {
        return self.rawValue + "UpdateTimeout"
    }
    
    private func updateReferanceValuesTimestamp() {
        let key = variableNameForUpdateTimeout()
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: key)
    }
    
}
