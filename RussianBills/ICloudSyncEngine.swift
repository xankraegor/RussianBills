//
//  ICloudSyncEngine.swift
//  RussianBills
//
//  Created by Xan Kraegor on 23.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import CloudKit

extension CKContainer {
    public static let shared = CKContainer(identifier: "iCloud.com.xankraegor.russianBills")
}

extension Notification.Name {
    public static let favoriteBillsDidChangeRemotely = Notification.Name(rawValue: "FavoriteBillsDidChangeRemotely")
    public static let remotePushChangesFeteched = Notification.Name(rawValue: "RemotePushChangesFeteched")
}

// MARK: - ENGINE

/// This class is responsible for observing changes to the local database and pushing them to CloudKit
/// as well as observing changes in CloudKit and syncing them to the local database
public final class ICloudSyncEngine: NSObject {

    // MARK: - Properties

    private struct Constants {
        static let previousChangeToken = "PreviousChangeToken"
        static let billRecordType = "FavoriteBill"
    }

    /// Realm notification token
    private var notificationToken: NotificationToken?
    /// CloudKit observer
    private var changesObserver: NSObjectProtocol?
    /// The CloudKit container the sync engine is using
    private let container: CKContainer
    /// The user's private CloudKit database
    private let privateDatabase: CKDatabase
    /// Local storage controller
    private let storage: BillSyncContainerStorage
    /// The modification date of the last favorite bill modified locally to use when querying the server
    private var modificationDateForQuery: Date {
        let date = storage.mostRecentlyModifiedBillSyncContainer?.favoriteUpdatedTimestamp ?? Date.distantPast
        slog("[Engine] modificationDateForQuery: \(date)")
        return date
    }
    /// Dispatch group for start operations to wait for
    private let startGroup = DispatchGroup()
    /// Holds the latest change token we got from CloudKit, storing it in UserDefaults
    private var previousChangeToken: CKServerChangeToken? {
        get {
            guard let tokenData = UserDefaults.standard.object(forKey: Constants.previousChangeToken) as? Data else { return nil }
            let token = NSKeyedUnarchiver.unarchiveObject(with: tokenData) as? CKServerChangeToken
            slog("[Engine] previousChangeToken.get:\(token?.description ?? "nil")")
            return token
        }
        set {
            slog("[Engine] previousChangeToken.set:\(newValue?.description ?? "nil")")
            guard let newValue = newValue else {
                UserDefaults.standard.setNilValueForKey(Constants.previousChangeToken)
                return
            }

            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(data, forKey: Constants.previousChangeToken)
        }
    }


    // MARK: - Init and workflow
    public init(storage: BillSyncContainerStorage, container: CKContainer = .shared) {
        slog("[Engine] init(storage: BillSyncContainerStorage, container: CKContainer = .shared)")
        self.storage = storage
        self.container = container
        self.privateDatabase = container.privateCloudDatabase
        super.init()
    }

    func start(completion: @escaping (Bool)->Void) {
        slog("[Engine] start()")
        UIApplication.shared.registerForRemoteNotifications()
        // Clean database before the app terminates
        NotificationCenter.default.addObserver(self, selector: #selector(cleanup(_:)), name: .UIApplicationWillTerminate, object: UIApplication.shared)

        // Fetch notifications not processed yet
        fetchServerNotifications(forced: false)
        // Do initial cloud fetch
        fetchCloudKitBills(force: false)
        // On-the-go sync subsriptions
        subscribeToLocalDatabaseChanges()
        subscribeToCloudKitChanges()

        slog("[Engine] start()_completion()")
        completion(true)

    }

    func stop() {
        slog("[Engine] stop()")
        cleanup()
        notificationToken?.invalidate()
        changesObserver = nil
        NotificationCenter.default.removeObserver(self)
        UIApplication.shared.unregisterForRemoteNotifications()
    }


    // MARK: - Start: Fetch Server Notifications part

    private func fetchServerNotifications(forced: Bool) {
        slog("[Engine] fetchServerNotifications(forced: \(forced))")
        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: previousChangeToken)
        // This will hold the identifiers for every changed record
        var updatedIdentifiers = [CKRecordID]()
        // This will hold the notification IDs we processed so we can tell CloudKit to never send them to us again
        var notificationIDs = [CKNotificationID]()

        operation.notificationChangedBlock = { [weak self] notification in
            guard let notification = notification as? CKQueryNotification, let identifier = notification.recordID else {
                return
            }
            if let id = notification.notificationID {
                notificationIDs.append(id)
            }
            DispatchQueue.main.async {
                slog("[Engine] fetchServerNotifications: server notification received from iCloud: \(notification.description), reason: \(notification.queryNotificationReason)")
                switch notification.queryNotificationReason {
                case .recordDeleted:
                    do {
                        try self?.storage.removeFromFavorites(with: identifier.recordName, hard: true)
                    } catch {
                        slog("[Engine] fetchServerNotifications: Error at deleting bill from cloud: \(error)")
                    }
                default:
                    updatedIdentifiers.append(identifier)
                }
            }
        }

        operation.fetchNotificationChangesCompletionBlock = { [weak self] newToken, error in
            slog("[Engine] fetchServerNotifications: competion block")
            guard error == nil else {
                self?.retryCloudKitOperationIfPossible(with: error) {
                    slog("[Engine] fetchServerNotifications: competion block error: \(error?.localizedDescription ?? "no description"). Will be repeated")
                    self?.fetchServerNotifications(forced: forced)
                }
                return
            }

            self?.previousChangeToken = newToken
            // All records are in, now save the data locally
            self?.consolidateUpdatedCloudBills(with: updatedIdentifiers)
            // Tell CloudKit we've read the notifications
            self?.markNotificationsAsRead(with: notificationIDs)
            slog("[Engine] fetchServerNotifications: competion block success")
        }

        container.add(operation)
    }

    /// Download a list of records from CloudKit and update the local database accordingly
    private func consolidateUpdatedCloudBills(with identifiers: [CKRecordID]) {
        slog("[Engine] consolidateUpdatedCloudBills(withIdentifiers:)")
        let operation = CKFetchRecordsOperation(recordIDs: identifiers)

        operation.fetchRecordsCompletionBlock = { [weak self] records, error in
            guard let records = records else {
                self?.retryCloudKitOperationIfPossible(with: error) {
                    self?.consolidateUpdatedCloudBills(with: identifiers)
                }
                return
            }

            records.values.forEach { record in
                self?.processFetchedBill(record)
            }
            slog("[Engine] consolidateUpdatedCloudBills: operation.fetchRecordsCompletionBlock: finished")
        }

        privateDatabase.add(operation)
        slog("[Engine] consolidateUpdatedCloudBills: success")
    }

    /// Sync a single bill to the local database
    private func processFetchedBill(_ cloudKitBill: CKRecord) {
        slog("[Engine] processFetchedBill(cloudKitBill: \(cloudKitBill.recordID.recordName))")
        DispatchQueue.main.async {
            guard let favoriteBill = FavoriteBill_.from(record: cloudKitBill) else {
                slog("[Engine] processFetchedBill(cloudKitBill: Error creating local bill from cloud bill \(cloudKitBill.recordID.recordName)")
                assertionFailure("Error creating local bill from cloud bill \(cloudKitBill.recordID.recordName)")
                return
            }

            do {
                try self.storage.store(favoriteBill: favoriteBill, notNotifying: self.notificationToken)
                NotificationCenter.default.post(name: .remotePushChangesFeteched, object: nil, userInfo: nil)
                slog("[Engine] FavoriteBill \(favoriteBill.number) stored to the container")
            } catch {
                slog("[Engine] Error saving local bill from cloud bill \(cloudKitBill.recordID.recordName): \(error)")
                assertionFailure("Error saving local bill from cloud bill \(cloudKitBill.recordID.recordName): \(error)")
            }
        }
    }

    private func markNotificationsAsRead(with identifiers: [CKNotificationID]) {
        slog("[Engine] markNotificationsAsRead(with identifiers: \(identifiers.count)")
        let operation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: identifiers)

        operation.markNotificationsReadCompletionBlock = { [weak self] _, error in
            guard error == nil else {
                slog("[Engine] markNotificationsAsRead: completion failed with error: \(String(describing: error?.localizedDescription))")
                self?.retryCloudKitOperationIfPossible(with: error) {
                    slog("[Engine] markNotificationsAsRead: completion will be repeated")
                    self?.markNotificationsAsRead(with: identifiers)
                }

                return
            }
            slog("[Engine] markNotificationsAsRead: completion success")
        }

        container.add(operation)
        slog("[Engine] markNotificationsAsRead: success")
    }

    // MARK: - Start: Fetch Cloud Kit Bills part

    /// Download bills from CloudKit
    private func fetchCloudKitBills(force: Bool, _ inputCursor: CKQueryCursor? = nil) {
        slog("[Engine] fetchCloudKitBills (force: \(force), _ inputCursor: CKQueryCursor? = \(String(describing: inputCursor))")
        let operation: CKQueryOperation

        // We may be starting a new query or continuing a previous one if there are many results
        if let cursor = inputCursor {
            operation = CKQueryOperation(cursor: cursor)
            slog("[Engine] fetchCloudKitBills: CKQueryOperation(cursor: cursor)")
        } else {
            // This query will fetch all bills modified since the last sync, sorted by modification date (descending)
            let predicate = force ? NSPredicate(value: true) : NSPredicate(format: "favoriteUpdatedTimestamp > %@", modificationDateForQuery as CVarArg)
            let query = CKQuery(recordType: Constants.billRecordType, predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: BillKey.favoriteUpdatedTimestamp.rawValue, ascending: false)]
            operation = CKQueryOperation(query: query)
            slog("[Engine] fetchCloudKitBills: CKQueryOperation(query: query)")
        }

        operation.queryCompletionBlock = { [weak self] cursor, error in
            slog("[Engine] fetchCloudKitBills: operation.queryCompletionBlock")
            guard error == nil else {
                self?.retryCloudKitOperationIfPossible(with: error) {
                    self?.fetchCloudKitBills(force: force, inputCursor)
                }
                return
            }

            if let cursor = cursor {
                // There are more results to come, continue fetching
                self?.fetchCloudKitBills(force: force, cursor)
            }

            slog("[Engine] fetchCloudKitBills: operation.queryCompletionBlock recursively finished (cursor not present)")
        }

        operation.recordFetchedBlock = { [weak self] record in
            slog("[Engine] fetchCloudKitBills:  operation.recordFetchedBlock")
            // When a bill is fetched from the cloud, process it into the local database
            self?.processFetchedBill(record)
        }

        privateDatabase.add(operation)
        slog("[Engine] fetchCloudKitBills: Operation added to the privateDatabase pipeline")
    }

    // MARK: - Start: Local subscription part

    private func subscribeToLocalDatabaseChanges() {
        slog("[Engine] subscribeToLocalDatabaseChanges()")
        let bills = storage.realm.objects(FavoriteBill_.self)

        // Here we subscribe to changes in bills to push them to CloudKit
        notificationToken = bills.observe { [weak self] changes in
            slog("[Engine] subscribeToLocalDatabaseChanges: notificationToken observe block")
            guard let welf = self else { return }

            switch changes {
            case .update(let collection, _, let insertions, let modifications):
                // Figure out which bills should be saved and which bills should be deleted
                let favoriteBillsToSave = (insertions + modifications).map {collection[$0]}.filter {!$0.markedToBeRemovedFromFavorites}
                let favoriteBillsToDelete = modifications.map { collection[$0]}.filter {$0.markedToBeRemovedFromFavorites}

                // Push changes to CloudKit
                welf.pushToCloudKit(billsToUpdate: favoriteBillsToSave, billsToDelete: favoriteBillsToDelete)
            case .error(let error):
                slog("[Engine] subscribeToLocalDatabaseChanges: Realm notification error: \(error)")
            default:
                break
            }
            slog("[Engine] subscribeToLocalDatabaseChanges: notificationToken observe block end")
        }
    }

    fileprivate func pushToCloudKit(billsToUpdate: [FavoriteBill_], billsToDelete: [FavoriteBill_]) {
        slog("[Engine] pushToCloudKit(billsToUpdate: [\(billsToUpdate.count)], billsToDelete: [\(billsToDelete.count)])")
        guard billsToUpdate.count > 0 || billsToDelete.count > 0 else {
            slog("[Engine] pushToCloudKit: Aborted, no bills to update")
            return
        }

        let recordsToSave = billsToUpdate.map({ $0.record })
        let recordsToDelete = billsToDelete.map({ $0.recordID })

        pushRecordsToCloudKit(recordsToUpdate: recordsToSave, recordIDsToDelete: recordsToDelete)
    }

    fileprivate func pushRecordsToCloudKit(recordsToUpdate: [CKRecord], recordIDsToDelete: [CKRecordID], completion: ((Error?) -> Void)? = nil) {
        slog("[Engine] pushRecordsToCloudKit (recordsToUpdate: \(recordsToUpdate.count), recordIDsToDelete: \(recordIDsToDelete.count), completion: ((Error?) -> Void)? = nil)")
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToUpdate, recordIDsToDelete: recordIDsToDelete)
        operation.savePolicy = .changedKeys

        operation.modifyRecordsCompletionBlock = { [weak self] _, _, error in
            guard error == nil else {
                slog("[Engine] pushRecordsToCloudKit: Error modifying records: \(error!)")

                self?.retryCloudKitOperationIfPossible(with: error) {
                    self?.pushRecordsToCloudKit(recordsToUpdate: recordsToUpdate, recordIDsToDelete: recordIDsToDelete,
                                                completion: completion)
                }
                return
            }

            DispatchQueue.main.async {
                slog("[Engine] pushRecordsToCloudKit: successful, run completion")
                completion?(nil)
            }
        }

        privateDatabase.add(operation)
    }

    // MARK: - Start: iCloud subscription part

    private func subscribeToCloudKitChanges() {
        slog("[Engine] subscribeToCloudKitChanges()")
        startObservingCloudKitChanges()

        // Create the CloudKit subscription so we receive push notifications when bills change remotely
        let subscription = CKQuerySubscription(recordType: Constants.billRecordType, predicate: NSPredicate(value: true),
                options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])

        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        info.soundName = ""
        subscription.notificationInfo = info

        privateDatabase.save(subscription) { [weak self] subscription, error in
            if subscription != nil {
                slog("[Engine] subscribeToCloudKitChanges: privateDatabase.save: success")
            } else {
                guard error == nil else {
                    slog("[Engine] subscribeToCloudKitChanges: privateDatabase.save: error: \(error?.localizedDescription ?? "no description")")
                    self?.retryCloudKitOperationIfPossible(with: error) {
                        self?.subscribeToCloudKitChanges()
                    }
                    return
                }
            }
        }
    }

    private func startObservingCloudKitChanges() {
        slog("[Engine] startObservingCloudKitChanges()")
        // The .billsDidChangeRemotely local notification is posted by the AppDelegate when it receives a push notification from CloudKit
        changesObserver = NotificationCenter.default.addObserver(forName: .favoriteBillsDidChangeRemotely, object: nil, queue: OperationQueue.main) { [weak self] _ in
            slog("[Engine] startObservingCloudKitChanges: oserver '.favoriteBillsDidChangeRemotely' activated")
            // When a notification is received from the server, we must download the notifications because they might have been coalesced
            self?.fetchServerNotifications(forced: false)
        }
    }

    // MARK: - Stop functions

    @objc func cleanup(_ notification: Notification? = nil) {
        NSLog("[Engine] cleanup(notification:)")
        do {
            try storage.deletePreviouslyUnfavoritedBills(notNotifying: self.notificationToken)
        } catch {
            NSLog("[Engine] cleanup: Failed to delete previously unfavorited bills: \(error)")
            assertionFailure("Failed to delete previously unfavorited bills: \(error)")
        }
    }

    // MARK: - Helper functions

    /// Helper method to retry a CloudKit operation when its error suggests it
    private func retryCloudKitOperationIfPossible(with error: Error?, completion: @escaping () -> Void) {
        slog("[Engine] retryCloudKitOperationIfPossible(with error: Error?, completion: @escaping () -> Void)")
        guard let error = error as? CKError else {
            slog("[Engine] retryCloudKitOperationIfPossible: error: interpret an error during retrying an operation")
            return
        }

        guard let retryAfter = error.userInfo[CKErrorRetryAfterKey] as? NSNumber else {
            slog("[Engine] retryCloudKitOperationIfPossible: CloudKit error: \(error)")
            return
        }

        slog("[Engine] retryCloudKitOperationIfPossible: CloudKit operation error \(error.localizedDescription), retrying after \(retryAfter) seconds...")

        DispatchQueue.main.asyncAfter(deadline: .now() + retryAfter.doubleValue) {
            completion()
        }
    }

    // MARK: - Sync resolve

    func isSyncResolveRequired(completion: @escaping (Bool?, _ with: Set<CKRecord>?)->Void ) {
        let query = CKQuery(recordType: Constants.billRecordType, predicate: NSPredicate(value: true))
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let _ = error {
                completion(nil, nil)
                return
            }

            if let receivedRecords = records {
                let cloudRecords = Set(receivedRecords)
                let diff = cloudRecords.symmetricDifference(receivedRecords)
                slog("isSyncResolveRequired: symmetric difference count: \(diff.count); diff = \n{\n\(diff)\n}")
                if diff.count > 0 {
                    completion(true, diff)
                } else {
                    completion(false, nil)
                }
            }
        }
    }

}
