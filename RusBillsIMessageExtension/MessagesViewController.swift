//
//  MessagesViewController.swift
//  RusBillsIMessageExtension
//
//  Created by Xan Kraegor on 30.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Messages
import RealmSwift

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var tableView: UITableView!


    lazy var realm: Realm? = {
        var config = Realm.Configuration()
        config.fileURL = FilesManager.defaultRealmPath()
        Realm.Configuration.defaultConfiguration = config
        let realm = try? Realm()
        return realm
    }()

    lazy var favoriteBillsFilteredAndSorted = realm?.objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.

        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.

        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.

        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

    // MARK: - Helper functions

    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30
    }
}

extension MessagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteBillsFilteredAndSorted!.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableViewCellId", for: indexPath) as! MessagesViewTableViewCell
        let favoriteBill = favoriteBillsFilteredAndSorted![indexPath.row]
        cell.numberLabel.text = "№\(favoriteBill.number)"
        cell.nameLabel.text = "\(favoriteBillsFilteredAndSorted![indexPath.row].name)[\(favoriteBill.comments)]".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let bill = favoriteBill.bill {
            cell.updatedLabel?.text = "Обновлен \(bill.lastEventDate)"
        }

        return cell
    }
}

extension MessagesViewController: UITableViewDelegate {

}
