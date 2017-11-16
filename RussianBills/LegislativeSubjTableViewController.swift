//
//  LegislativeSubjTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class LegislativeSubjTableViewController: UITableViewController {

    var subjectType: LegislativeSubjectType? = nil
    var id: Int? = nil

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var isCurrentLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let subjectType = subjectType, let id = id else {
            return
        }

        if let item = subjectType.item(byId: id) {
            setMainLabels(forItem: item)
        }
    }


    // MARK: - Helper functions

    func setMainLabels(forItem item: Object) {
        if let fedSubj = item as? FederalSubject_ {
            nameLabel.text = fedSubj.name
            lookupForAddressWithName(name: fedSubj.name)
            typeLabel.text = "Федеральный орган власти"
            var currentText = fedSubj.isCurrent ? "Действует c " : "Действовал c "
            currentText.append(contentsOf: fedSubj.startDate)
            if !fedSubj.isCurrent {
                currentText.append(contentsOf: " по \(fedSubj.stopDate.isoDateToReadableDate() ?? fedSubj.stopDate)")
            }
            isCurrentLabel.text = currentText
        } else if let regSubj = item as? RegionalSubject_ {
            nameLabel.text = regSubj.name
            lookupForAddressWithName(name: regSubj.name)
            typeLabel.text = "Региональный орган власти"
            var currentText = regSubj.isCurrent ? "Действует c " : "Действовал c "
            currentText.append(contentsOf: regSubj.startDate.isoDateToReadableDate() ?? regSubj.startDate)
            if !regSubj.isCurrent {
                currentText.append(contentsOf: " по \(regSubj.stopDate.isoDateToReadableDate() ?? regSubj.stopDate)")
            }
            isCurrentLabel.text = currentText
        } else if let deputy = item as? Deputy_ {
            nameLabel.text = deputy.name
            lookupForAddressWithName(name: deputy.name)
            typeLabel.text = deputy.position
            isCurrentLabel.text = deputy.isCurrent ? "Полномочия действуют" : "Срок полномочий истёк"
        }
    }

    // MARK: - Location Services

    func lookupForAddressWithName(name: String) {

    }

}
