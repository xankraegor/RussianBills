//
//  WatchSessionManager.swift
//  WatchConnectivityDemo
//
//  Created by Natasha Murashev on 9/3/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//  Updated by Anton Alekseev on 12/5/17
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import WatchConnectivity
import RealmSwift

class WatchSessionManager: NSObject, WCSessionDelegate {

    /// Singleton
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }

    /// RealmObjects to handle
    let favoriteBills = try? Realm().objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])
    var favoritesRealmNotificationToken: NotificationToken?

    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    fileprivate var validSession: WCSession? {

        if let s = session, s.isWatchAppInstalled && s.isPaired {
            return s
        }
        return nil
    }

    func startSession() {
        session?.delegate = self
        session?.activate()
        setupRealmHandle()
    }

    func setupRealmHandle() {
        favoritesRealmNotificationToken = favoriteBills?.observe { [weak self] (_) -> Void in
            self?.sendContextToWatch()
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            sendMessageToWatch()
        }
    }

    func sendContextToWatch() {
        guard let favs = self.favoriteBills else { return }
        var bills: [[String: String]] = [[:]]
        DispatchQueue.main.async {
            for bill in favs {
                let wb = FavoriteBillForWatchOS(withFavoriteBill: bill).dictionary()
                bills.append(wb)
            }

            try? self.updateApplicationContext(applicationContext: ["favoriteBills": bills])
        }
    }

    func sendMessageToWatch() {
        guard let favs = self.favoriteBills else { return }
        var bills: [[String: String]] = [[:]]
        DispatchQueue.main.async {
            for bill in favs {
                let wb = FavoriteBillForWatchOS(withFavoriteBill: bill).dictionary()
                bills.append(wb)
            }

            self.sendMessage(message: ["favoriteBills": bills])
        }
    }

    /**
     * Called when the session has completed activation.
     * If session state is WCSessionActivationStateNotActivated there will be an error with more details.
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    /**
     * Called when the session can no longer be used to modify or add any new transfers and,
     * all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur.
     * This will happen when the selected watch is being changed.
     */
    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    /**
     * Called when all delegate callbacks for the previously selected watch has occurred.
     * The session can be re-activated for the now selected watch using activateSession.
     */
    func sessionDidDeactivate(_ session: WCSession) {

    }
}

// MARK: Application Context
// use when your app needs only the latest information
// if the data was not sent, it will be replaced
extension WatchSessionManager {

    // Sender
    func updateApplicationContext(applicationContext: [String: Any]) throws {
        if let session = validSession {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }

    // Receiver
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {

    }
}

// MARK: User Info
// use when your app needs all the data
// FIFO queue
extension WatchSessionManager {

    // Sender
    func transferUserInfo(userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {

    }

    // Receiver
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {

    }

}

// MARK: Transfer File
extension WatchSessionManager {

    // Sender
    func transferFile(file: NSURL, metadata: [String: Any]) -> WCSessionFileTransfer? {
        return validSession?.transferFile(file as URL, metadata: metadata)
    }

    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        // handle filed transfer completion
    }

    // Receiver
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // handle receiving file
        DispatchQueue.main.async() {
            // make sure to put on the main queue to update UI!
        }
    }
}

// MARK: Interactive Messaging
extension WatchSessionManager {

    // Live messaging! App has to be reachable
    private var validReachableSession: WCSession? {
        if let session = validSession, session.isReachable {
            return session
        }
        return nil
    }

    // Sender
    func sendMessage(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }

    func sendMessageData(data: Data, replyHandler: ((Data) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }

    // Receiver
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {

    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {

    }
}
