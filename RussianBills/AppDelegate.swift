//
//  AppDelegate.swift
//  RussianBills
//
//  Created by Xan Kraegor on 03.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var syncman: SyncMan?
    private var iCloudSyncEngine: IcloudSyncEngine?
    private let storage = BillSyncContainerStorage()
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Firebase
        FirebaseApp.configure()

        // Realm
        var config = Realm.Configuration()
        config.fileURL = FilesManager.defaultRealmPath()
        Realm.Configuration.defaultConfiguration = config
        let realm = try? Realm()
        let quickSearchList = BillsList_(withName: BillsListType.quickSearch, totalCount: 0)
        let mainSearchList = BillsList_(withName: BillsListType.mainSearch, totalCount: 0)
        try? realm?.write {
            realm?.add(quickSearchList, update: true)
            realm?.add(mainSearchList, update: true)
        }

        // Initializing sync manager
        syncman = SyncMan.shared

        // Initalizing iCloud sync engaine
        UIApplication.shared.registerForRemoteNotifications()
        iCloudSyncEngine = IcloudSyncEngine(storage: storage)

        // Enabling user notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        // Other actions
        UserServices.downloadAllReferenceCategories(forced: true)
        UserServices.updateFavoriteBills(forced: false) {
            unseenFavoriteBillsCount in
            NotificationCenter.default.post(name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil, userInfo: ["count": unseenFavoriteBillsCount])
            SyncMan.shared.appBadgeToUnseenChangedFavoriteBills(unseenFavoriteBillsCount)

        }

        return true
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }

    func applicationWillResignActive(_ application: UIApplication) {
        SyncMan.shared.foregroundFavoriteBillsUpdateTimer?.invalidate()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       backgroundTask = application.beginBackgroundTask(withName: "BackgroundFavoriteBillsUpdating", expirationHandler: {
        [weak self] in
        print("Did enter background")
        UserServices.updateFavoriteBills(forced: false, completeWithUpdatedCount: {
            [weak self] (unseenFavoriteBillsCount) in
            NotificationCenter.default.post(name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil, userInfo: ["count": unseenFavoriteBillsCount])
            SyncMan.shared.appBadgeToUnseenChangedFavoriteBills(unseenFavoriteBillsCount)
            self?.endBackgroundTask()
        })
       })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SyncMan.shared.setupForegroundUpdateTimer(fireNow: true)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCenter.default.post(name: .favoriteBillsDidChangeRemotely, object: nil, userInfo: userInfo)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        debugPrint("Вызов обновления избранных законопроектов в фоне")
        let updated = SyncMan.shared.favoriteBillsLastUpdate
        let timeout = UserDefaultsCoordinator.favoriteBillsUpdateTimeout()
        if let upd = updated, abs(upd.timeIntervalSinceNow) < timeout {
            print("Фоновое обновление избранных законопроектов не требуется")
            completionHandler(.noData)
            return
        }

        Dispatcher.shared.favoriteBillsUpdateTimer
            = DispatchSource.makeTimerSource(queue: DispatchQueue.main)

        Dispatcher.shared.favoriteBillsUpdateTimer?.schedule(deadline: .now(), repeating: DispatchTimeInterval.seconds(29), leeway: .seconds(1))
        Dispatcher.shared.favoriteBillsUpdateTimer?.resume()

        Dispatcher.shared.favoriteBillsUpdateTimer?.setEventHandler {
            debugPrint("Фоновое обновление избранных законопроектов не выполенено в срок")
            completionHandler(.failed)
            return
        }

        Dispatcher.shared.favoritesUpdateDispatchGroup.enter()
        UserServices.updateFavoriteBills(forced: true) {
            unseenFavoriteBillsCount in
            NotificationCenter.default.post(name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil, userInfo: ["count": unseenFavoriteBillsCount])
            SyncMan.shared.appBadgeToUnseenChangedFavoriteBills(unseenFavoriteBillsCount)
        }
        Dispatcher.shared.favoritesUpdateDispatchGroup.leave()

        Dispatcher.shared.favoritesUpdateDispatchGroup.notify(queue: DispatchQueue.main) {
            print ("Все данные загружены в фоне")
            Dispatcher.shared.favoriteBillsUpdateTimer = nil
            completionHandler(.newData)
            return
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("∆∆ application(_ app: UIApplication, open url: \(url), options: \(options)")

        if url.scheme == "russianbills", let host = url.host {
            if host == "favorites" {

                let mainSB = UIStoryboard(name: "Main", bundle: nil)

                guard let mainVC = mainSB.instantiateViewController(withIdentifier: "MainSceneID") as? MainTableViewController else {
                    assertionFailure()
                    return false
                }

                let favoritesVC = mainSB.instantiateViewController(withIdentifier: "FavoritesSceneID")
                (self.window?.rootViewController as? UINavigationController)?.pushViewController(mainVC, animated: false)
                (self.window?.rootViewController as? UINavigationController)?.pushViewController(favoritesVC, animated: false)

                return true
            }
        }

        return false
    }
}
