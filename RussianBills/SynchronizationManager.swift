//
//  SynchronizationManager.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications
import CloudKit

/// Main Synchronization Class
final class SyncMan {
    static let shared = SyncMan() // Singleton
    
    let favoriteBillsInRealm = try? Realm().objects(FavoriteBill_.self)
    var foregroundFavoriteBillsUpdateTimer: Timer?

    // MARK: - Initialization

    private init() {

        setupForegroundUpdateTimer()

        iCloudStorage = BillSyncContainerStorage()
        if let storage = iCloudStorage {
            iCloudSyncEngine = IcloudSyncEngine(storage: storage)
        }

    }

    // MARK: - Updating favorite bills

    var favoriteBillsUpdateTimer: DispatchSourceTimer?

    func setupForegroundUpdateTimer(fireNow: Bool = false) {
        foregroundFavoriteBillsUpdateTimer = Timer.scheduledTimer(withTimeInterval: UserDefaultsCoordinator.favoriteBillsUpdateTimeout(), repeats: true, block: { (_) in
            UserServices.updateFavoriteBills(forced: false)
        })

        if fireNow {
            foregroundFavoriteBillsUpdateTimer?.fire()
        }
    }

    var favoriteBillsLastUpdate: Date? {
        let timestamp = UserDefaults.standard.double(forKey: "favoritesUpdateTimestamp")
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        // Set directly by UserServices.updateFavoriteBills function
    }

    func appBadgeToUnseenChangedFavoriteBills(_ usingCount: Int? = nil) {
        let count = usingCount ?? favoriteBillsInRealm?.filter(FavoritesFilters.both.rawValue).count ?? 0
        UIApplication.shared.applicationIconBadgeNumber = count
    }

    // MARK: - iCloud Synchronization

    let icloudDb = CKContainer.default().database(with: .private)
    var iCloudSyncEngine: IcloudSyncEngine?
    var iCloudStorage: BillSyncContainerStorage?

    func isUserLoggedIntoIcloud(withResult: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus(completionHandler: {(_ accountStatus: CKAccountStatus, _ error: Error?) -> Void in
            if accountStatus == .noAccount {
                withResult(false)
            } else {
                withResult(true)
            }
        })
    }

}
