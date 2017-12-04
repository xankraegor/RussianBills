//
//  MainTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit

final class MainTableViewController: UITableViewController {

    @IBOutlet weak var updatedFavoriteBillsCountLabel: UILabel?


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Default realm path: \(Realm.Configuration.defaultConfiguration.fileURL?.path ?? "missing")")
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }

        updatedFavoriteBillsCountLabel?.layer.cornerRadius = 10
        updatedFavoriteBillsCountLabel?.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        let favoriteBillsWithUnseenChangesCount = try? Realm().objects(FavoriteBill_.self).filter(FavoritesFilters.both.rawValue).count
        setFavoritesBadge(count: favoriteBillsWithUnseenChangesCount ?? 0)
    }

    // MARK: - Notifications

    @objc func methodOfReceivedNotification(notification: Notification){
        if let dict = notification.userInfo as? [String: Int], let count = dict["count"] {
            setFavoritesBadge(count: count)
        }
    }

    // MARK: - Helper functions

    func setFavoritesBadge(count: Int) {
        if count > 0 {
            updatedFavoriteBillsCountLabel?.text = "  \(count)  "
            updatedFavoriteBillsCountLabel?.isHidden = false
        } else {
            updatedFavoriteBillsCountLabel?.isHidden = true
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
                case "CommittiesSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.committees
                case "FederalSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.federalSubjects
                case "RegionalSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.regionalSubjects
                case "InstancesSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.instances
                case "DeputiesSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.dumaDeputees
                case "CouncilSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.councilMembers
            default:
                break
            }
        }
    }

    // MARK: - Debug


    @IBAction func syncButtonPressed(_ sender: Any) {
         SyncMan.shared.writeToIcloud()
    }

}
