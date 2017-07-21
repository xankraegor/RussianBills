//
//  BillDetailsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 20.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class BillDetailsTableViewController: UITableViewController {
    
    var tree: [BillParserPhase]?
    var navigationTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard tree != nil else {
            fatalError("∆ No parsed data handed to BillDetailsTableViewController")
        }

        if let navigationTitle = navigationTitle {
            self.navigationItem.title = "События 📃\(navigationTitle)"
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tree!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree![section].events.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tree![section].name
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventDescriptionCell", for: indexPath) as! EventDescriptionTableViewCell
        cell.eventDateLabel.text = tree![indexPath.section].events[indexPath.row].date
        cell.eventDocumentLabel.text = tree![indexPath.section].events[indexPath.row].docNr
        cell.eventTextLabel.text = tree![indexPath.section].events[indexPath.row].name
        let docsCount = tree![indexPath.section].events[indexPath.row].attachments.count
        if docsCount > 0 {
            cell.documentsAttachedLabel.text = "📘 Документы: \(docsCount)"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        } else {
            cell.documentsAttachedLabel.text = ""
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
            dest.event = tree![indexPath.section].events[indexPath.row]
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = tableView.indexPathForSelectedRow {
            return tree![indexPath.section].events[indexPath.row].attachments.count > 0
        }
        return false
    }

}
