//
//  TopicsViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

class SimpleTableViewController: UITableViewController {

    var objectsToDisplay: SimpleTableViewControllerSelector?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = objectsToDisplay!.fullDescription
        self.navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        switch objectsToDisplay! {
        case .lawClasses: UserServices.downloadLawCalsses { [weak self] in
            self?.updateTableWithNewData()}
        case .topics: UserServices.downloadTopics { [weak self] in
            self?.updateTableWithNewData()}
        case .committees: UserServices.downloadComittees { [weak self] in
            self?.updateTableWithNewData()}
        case .federalSubjects: UserServices.downloadFederalSubjects { [weak self] in
            self?.updateTableWithNewData()}
        case .regionalSubjects: UserServices.downloadFederalSubjects { [weak self] in
            self?.updateTableWithNewData()}
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
            let objct = RealmCoordinator.loadObject(ofType: LawClass_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
             return cell
        case .topics:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = RealmCoordinator.loadObject(ofType: Topic_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
             return cell
        case .federalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = RealmCoordinator.loadObject(ofType: FederalSubject_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
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
            let objct = RealmCoordinator.loadObject(ofType: RegionalSubject_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
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
            let objct = RealmCoordinator.loadObject(ofType: Comittee_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell
        }

    }


    private func updateTableWithNewData() {
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
