//
//  BillCardTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class BillCardTableViewController: UITableViewController {
    
    var bill: Bill_?
    
    @IBOutlet weak var numberLabel: UILabel!
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
    
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        if let bill = bill {
            debugPrint(bill)

            numberLabel.text = "№ \(bill.number)"
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

    // MARK: - Table view delegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }



}
