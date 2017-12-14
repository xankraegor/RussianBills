//
//  BillDetailsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 20.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class BillDetailsTableViewController: UITableViewController {

    var parserContent: BillParserContent?
    var billNumber: String?
    var bill: Bill_?
    var realmNotificationToken: NotificationToken?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        installRealmToken()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        navigationController?.isToolbarHidden = true
        if let navigationTitle = billNumber {
            self.navigationItem.title = "События з/п. № \(navigationTitle)"
        }
    }

    deinit {
        realmNotificationToken?.invalidate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return parserContent?.phases.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parserContent?.phases[section].events.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return parserContent?.phases[section].name ?? ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventDescriptionCell", for: indexPath) as! EventDescriptionTableViewCell
        cell.eventDateLabel?.text = parserContent!.phases[indexPath.section].events[indexPath.row].date
        cell.eventDocumentLabel?.text = parserContent!.phases[indexPath.section].events[indexPath.row].docNr
        cell.eventTextLabel?.text = parserContent!.phases[indexPath.section].events[indexPath.row].name
        let docsCount = parserContent?.phases[indexPath.section].events[indexPath.row].attachments.count ?? 0
        if docsCount > 0 {
            cell.documentsAttachedLabel?.text = "📘 Документы: \(docsCount)"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        } else {
            cell.documentsAttachedLabel?.text = ""
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BillAttachedDocumentsTableViewController, let indexPath = tableView.indexPathForSelectedRow {
            dest.event = parserContent!.phases[indexPath.section].events[indexPath.row]
            dest.billNumber = self.billNumber
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = tableView.indexPathForSelectedRow {
            return parserContent!.phases[indexPath.section].events[indexPath.row].attachments.count > 0
        }
        return false
    }

    // MARK: - Helper functions

    func installRealmToken() {
        if let currentBill = bill {
            realmNotificationToken = currentBill.observe { [weak self] (_) -> Void in
                if currentBill.parserContent != nil, let newContent = BillParserContent.deserialize(data: currentBill.parserContent!) {
                    self?.parserContent = newContent
                    self?.tableView.reloadData()
                }
            }
        }
    }

}
