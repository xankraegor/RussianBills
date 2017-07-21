//
//  BillCardTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Kanna

final class BillCardTableViewController: UITableViewController {
    
    var bill: Bill_?

    @IBOutlet weak var billTypeLabel: UILabel!
    @IBOutlet weak var billTitle: UILabel!
    @IBOutlet weak var billSubtitleLabel: UILabel!
    @IBOutlet weak var introductionDateLabel: UILabel!
    @IBOutlet weak var introductedByLabel: UILabel!
    
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var decisionLabel: UILabel!
    
    @IBOutlet weak var respCommitteeLabel: UILabel!
    @IBOutlet weak var coexecCommitteeLabel: UILabel!
    @IBOutlet weak var profileComitteesLable: UILabel!
    
    @IBOutlet weak var goToAllEventsCell: UITableViewCell!

    var parser: BillParser? {
        didSet {
            if parser != nil {
                goToAllEventsCell.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        fetchBillData()

        if let billUrlString = bill?.url,
            let billUrl = URL(string: billUrlString) {
            Request.htmlToParse(forUrl: billUrl, completion: { (html) in
                self.parser = BillParser(withHTML: html)
            })

        }
    }

    // MARK: - Table view delegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - Helper functions

    func fetchBillData() {
        if let bill = bill {
            navigationItem.title = "📃\(bill.number)"
            billTypeLabel.text = bill.lawType.description
            billTitle.text = bill.name
            billSubtitleLabel.text = bill.comments
            introductionDateLabel.text = bill.introductionDate
            introductedByLabel.text = bill.generateSubjectsDescription()
            stageLabel.text = bill.lastEventStage?.name
            phaseLabel.text = bill.lastEventPhase?.name
            decisionLabel.text = bill.generateFullSolutionDescription()
        } else {
            fatalError("Bill is not being provided")
        }
    }
    
    // MARK: - Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillDetailsSegue" {
            if let dest = segue.destination as? BillDetailsTableViewController, let tree = parser?.tree {
                dest.tree = tree
                dest.navigationTitle = "\(bill!.number)"
            }
        }
    }

}
