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
    private var iCloudSyncEngine: IcloudSyncEngine!
    private let storage = BillSyncContainerStorage()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Firebase
        FirebaseApp.configure()

        // Realm
        var config = Realm.Configuration()
        config.fileURL = FilesManager.defaultRealmPath()
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        let quickSearchList = BillsList_(withName: BillsListType.quickSearch)
        let mainSearchList = BillsList_(withName: BillsListType.mainSearch)
        try! realm.write {
            realm.add(quickSearchList, update: true)
            realm.add(mainSearchList, update: true)
        }

        // Initializing sync manager
        syncman = SyncMan.shared

        iCloudSyncEngine = IcloudSyncEngine(storage: storage)

        // Enabling user notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        // Other actions
        UserServices.downloadAllReferenceCategories()
        UserServices.updateFavoriteBills(forced: true) {
            unseenFavoriteBillsCount in
            NotificationCenter.default.post(name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil, userInfo: ["count": unseenFavoriteBillsCount])
            SyncMan.shared.appBadgeToUnseenChangedFavoriteBills(unseenFavoriteBillsCount)

        }

        return true
    }



    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        debugPrint("Вызов обновления избранных законопроектов в фоне")
        let updated = SyncMan.shared.favoriteBillsLastUpdate
        let timeout = UserDefaultsCoordinator.favoriteBillsUpdateTimeout()
        if updated != nil, abs(updated!.timeIntervalSinceNow) < timeout {
            print("Фоновое обновление избранных законопроектов не требуется")
            completionHandler(.noData)
            return
        }

        Dispatcher.shared.favoriteBillsUpdateTimer
            = DispatchSource.makeTimerSource(queue: DispatchQueue.main)

        Dispatcher.shared.favoriteBillsUpdateTimer?.schedule(deadline: .now(), repeating: DispatchTimeInterval.seconds(Int(timeout) - 1), leeway: .seconds(1))

        Dispatcher.shared.favoriteBillsUpdateTimer?.setEventHandler {
            debugPrint("Фоновое обновление избранных законопроектов не выполенено в срок")
            completionHandler(.failed)
            return
        }

        Dispatcher.shared.favoriteBillsUpdateTimer?.resume()

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
}
