//
//  WatchSessionManager.swift
//  WatchConnectivityDemo
//
//  Created by Natasha Murashev on 9/3/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//  Updated by Anton Alekseev on 12/5/17
//  Copyright © 2017 XanKraegor. All rights reserved.
//

import WatchConnectivity
import WatchKit

class WatchSessionManager: NSObject, WCSessionDelegate {

    public var favoriteBills: [FavoriteBillForWatchOS] {
        return favoriteBills_
    }
    private var favoriteBills_: [FavoriteBillForWatchOS] = []

    static let shared = WatchSessionManager()
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    fileprivate let notifCenter = NotificationCenter.default

    private override init() {
        super.init()
    }

    func startSession() {
        session?.delegate = self
        session?.activate()
    }

    /**
     * Called when the session has completed activation.
     * If session state is WCSessionActivationStateNotActivated there will be an error with more details.
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

}

// MARK: Application Context
// use when your app needs only the latest information
// if the data was not sent, it will be replaced
extension WatchSessionManager {

    // Sender
    func updateApplicationContext(applicationContext: [String: Any]) throws {
        if let session = session {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }

    // Receiver
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async() {
            let payload = applicationContext["favoriteBills"] as! [[String: String]]
            var favBills: [FavoriteBillForWatchOS] = []
            for favoriteBillDictionary in payload {
                if let fb = FavoriteBillForWatchOS(withDictionary: favoriteBillDictionary) {

                    favBills.append(fb)
                } else {
                    continue
                }
            }

            let notificationWithContext = Notification(name: Notification.Name(rawValue: "watchReceivedUpdatedData"), object: nil, userInfo: ["favoriteBills": favBills])
            self.notifCenter.post(notificationWithContext)
        }
    }
}

// MARK: User Info
// use when your app needs all the data
// FIFO queue
extension WatchSessionManager {

    // Sender
    func transferUserInfo(userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return session?.transferUserInfo(userInfo)
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        // implement this on the sender if you need to confirm that
        // the user info did in fact transfer
    }

    // Receiver
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        // handle receiving user info
        //        DispatchQueue.main.async() {
        // make sure to put on the main queue to update UI!
        //        }
    }
}

// MARK: Transfer File
extension WatchSessionManager {

    // Sender
    func transferFile(file: NSURL, metadata: [String: Any]) -> WCSessionFileTransfer? {
        return session?.transferFile(file as URL, metadata: metadata)
    }

    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        // handle filed transfer completion
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // handle receiving file
        // DispatchQueue.main.async() {
        // make sure to put on the main queue to update UI!
        // }
    }

}

// MARK: Interactive Messaging
extension WatchSessionManager {

    // Live messaging! App has to be reachable
    private var validReachableSession: WCSession? {
        if let session = session, session.isReachable {
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
        DispatchQueue.main.async() {
            let payload = message["favoriteBills"] as! [[String: String]]
            var favBills: [FavoriteBillForWatchOS] = []
            for favoriteBillDictionary in payload {
                if let fb = FavoriteBillForWatchOS(withDictionary: favoriteBillDictionary) {

                    favBills.append(fb)
                } else {
                    continue
                }
            }

            let notificationWithContext = Notification(name: Notification.Name(rawValue: "watchReceivedUpdatedData"), object: nil, userInfo: ["favoriteBills": favBills])
            self.notifCenter.post(notificationWithContext)
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        // handle receiving message data
        // DispatchQueue.main.async() {
        // make sure to put on the main queue to update UI!
        // }
    }
}
