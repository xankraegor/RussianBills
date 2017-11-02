//
//  MainTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class MainTableViewController: UITableViewController {
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Default realm path: \(Realm.Configuration.defaultConfiguration.fileURL?.path ?? "missing")")
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "LawClassesSegue":
                (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.lawClasses
            case "TopicsSegue":
                (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.topics
                case "CommitteesSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.committees
                case "FederalSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.federalSubjects
                case "RegionalSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.regionalSubjects
                case "InstancesSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.instances
                case "DeputeesSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.deputees
            default:
                break
            }
        }
    }

}
