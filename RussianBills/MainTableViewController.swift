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

    @IBOutlet weak var updatedFavoriteBillsCountLabel: UILabel!

    let realm = try? Realm()

    lazy var favoriteBillsWithUnseenChangesCount = {
        return (try? Realm().objects(Bill_.self).filter("favoriteHasUnseenChanges == true").count) ?? 0
    }()


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Default realm path: \(Realm.Configuration.defaultConfiguration.fileURL?.path ?? "missing")")
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }

        updatedFavoriteBillsCountLabel.layer.cornerRadius = 10
        updatedFavoriteBillsCountLabel.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("newUpdatedFavoriteBillsCountNotification"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        favoriteBillsWithUnseenChangesCount = (try? Realm().objects(Bill_.self).filter("favoriteHasUnseenChanges == true").count) ?? 0
        setFavoritesBadge(count: favoriteBillsWithUnseenChangesCount)
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
            updatedFavoriteBillsCountLabel.text = "  \(count)  "
            updatedFavoriteBillsCountLabel.isHidden = false
        } else {
            updatedFavoriteBillsCountLabel.isHidden = true
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
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.dumaDeps
                case "CouncilSegue":
                    (segue.destination as? SimpleTableViewController)?.objectsToDisplay = SimpleTableViewControllerSelector.councilMems
            default:
                break
            }
        }
    }

}
