//
//  MainTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("Realm DB Path: \(RealmCoordinator.defaultRealmPath())\n")
        UserServices.downloadAllReferenceCategories()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "LawClassesSegue":
                (segue.destination as! SimpleTableViewController).objectsToDisplay = SimpleTableViewControllerSelector.lawClasses
            case "TopicsSegue":
                (segue.destination as! SimpleTableViewController).objectsToDisplay = SimpleTableViewControllerSelector.topics
                case "CommitteesSegue":
                (segue.destination as! SimpleTableViewController).objectsToDisplay = SimpleTableViewControllerSelector.committees
                case "FederalSegue":
                (segue.destination as! SimpleTableViewController).objectsToDisplay = SimpleTableViewControllerSelector.federalSubjects
                case "RegionalSegue":
                (segue.destination as! SimpleTableViewController).objectsToDisplay = SimpleTableViewControllerSelector.regionalSubjects
                case "InstancesSegue":
                (segue.destination as! SimpleTableViewController).objectsToDisplay = SimpleTableViewControllerSelector.instances
            default:
                break
            }
        }
    }

}
