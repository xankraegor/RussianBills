//
//  TopicsViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class SimpleTableViewController: UITableViewController {

    var objectsToDisplay: SimpleTableViewControllerSelector?


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if objectsToDisplay == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = objectsToDisplay!.fullDescription
        self.navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func viewDidAppear(_ animated: Bool) {
        switch objectsToDisplay! {
        case .lawClasses:
            UserServices.downloadLawCalsses { [weak self] in
            self?.updateTableWithNewData()
            }
        case .topics:
            UserServices.downloadTopics { [weak self] in
            self?.updateTableWithNewData()
            }
        case .committees:
            UserServices.downloadComittees { [weak self] in
            self?.updateTableWithNewData()
            }
        case .federalSubjects:
            UserServices.downloadFederalSubjects { [weak self] in
            self?.updateTableWithNewData()
            }
        case .regionalSubjects:
            UserServices.downloadFederalSubjects { [weak self] in
            self?.updateTableWithNewData()
            }
        case .instances:
            UserServices.downloadInstances { [weak self] in
                self?.updateTableWithNewData()
            }
        case .deputees:
            UserServices.downloadInstances() { [weak self] in
                self?.updateTableWithNewData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmCoordinator.countObjects(ofType: (objectsToDisplay?.typeUsedForObjects)!) 
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch objectsToDisplay! {

        case .lawClasses:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = RealmCoordinator.loadObject(LawClass_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
             return cell

        case .topics:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = RealmCoordinator.loadObject(Topic_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
             return cell

        case .instances:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = RealmCoordinator.loadObject(Instance_.self, sortedBy: "id", ascending: false, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
            return cell

        case .federalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = RealmCoordinator.loadObject(FederalSubject_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
             return cell

        case .regionalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = RealmCoordinator.loadObject(RegionalSubject_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
             return cell

        case .committees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = RealmCoordinator.loadObject(Comittee_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell
            
        case .deputees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeputeesCellId", for: indexPath)
            let objct = RealmCoordinator.loadObject(Deputy_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
            cell.detailTextLabel?.text = (objct.isCurrent ? "✅ Действующий " : "⏹ Бывший ") + objct.position
            return cell
        }

    }

    // MARK: - Helper functions

    private func updateTableWithNewData() {
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
