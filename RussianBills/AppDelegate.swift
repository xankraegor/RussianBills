//
//  AppDelegate.swift
//  RussianBills
//
//  Created by Xan Kraegor on 03.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var syncman: SyncMan?
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Crashlythics
        let path = Bundle.main.path(forResource: "fabric", ofType: "apikey")!
        let key = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let trimmedKey = key.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        Fabric.with([Crashlytics.self.start(withAPIKey: trimmedKey)])

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

        // Initializing Synchronization manager

        syncman = SyncMan.shared

        // Enabling user notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert]) { (granted, error) in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        // Initializing Watch Session
        WatchSessionManager.sharedManager.startSession()

        // Other actions
        UserServices.downloadAllReferenceCategories(forced: true)
        UserServices.updateFavoriteBills(forced: false) {
            unseenFavoriteBillsCount in
            NotificationCenter.default.post(name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil, userInfo: ["count": unseenFavoriteBillsCount])
            SyncMan.shared.appBadgeToUnseenChangedFavoriteBills(unseenFavoriteBillsCount)

        }

        // Color Scheme
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Фильтровать", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        UISearchBar.appearance().tintColor = UIColor.white


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

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCenter.default.post(name: .favoriteBillsDidChangeRemotely, object: nil, userInfo: userInfo)
        completionHandler(.newData)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let updated = SyncMan.shared.favoriteBillsLastUpdate
        let timeout = UserDefaultsCoordinator.favoriteBillsUpdateTimeout()
        if let upd = updated, abs(upd.timeIntervalSinceNow) < timeout {
            completionHandler(.noData)
            return
        }

        Dispatcher.shared.favoriteBillsUpdateTimer
            = DispatchSource.makeTimerSource(queue: DispatchQueue.main)

        Dispatcher.shared.favoriteBillsUpdateTimer?.schedule(deadline: .now(), repeating: DispatchTimeInterval.seconds(29), leeway: .seconds(1))
        Dispatcher.shared.favoriteBillsUpdateTimer?.resume()

        Dispatcher.shared.favoriteBillsUpdateTimer?.setEventHandler {
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
            Dispatcher.shared.favoriteBillsUpdateTimer = nil
            completionHandler(.newData)
            return
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        if url.scheme == "rusBills", let host = url.host, host == "favorites" {

            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

            // Open favorites scene
            let navigationController = mainStoryboard.instantiateInitialViewController() as! UINavigationController
            let favoritesVC = mainStoryboard.instantiateViewController(withIdentifier: "FavoritesSceneID")
            navigationController.pushViewController(favoritesVC, animated: false)

            // Open bill card scene
            if url.pathComponents[1].count > 0 {
                let billVC = mainStoryboard.instantiateViewController(withIdentifier: "BillCardTableViewControllerId") as! BillCardTableViewController
                billVC.billNr = url.pathComponents[1]
                navigationController.pushViewController(billVC, animated: false)
            }

            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            return true

        }

        return false
    }
}
