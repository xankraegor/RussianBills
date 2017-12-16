//
//  UserDefaultsCoordinator+Sync.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

// MARK: - iCloud Sync
extension UserDefaultsCoordinator {
    static var iCloudSyncTurnedOn: Bool {
        get {
            return UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.bool(forKey: "isICloudSyncActive")
        }
        set {
            UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(newValue, forKey: "isICloudSyncActive")
        }
    }
}
