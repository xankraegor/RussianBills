//
//  SearchResultsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 19.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResultsTableViewController: UITableViewController {

    var query = BillSearchQuery()
    var isLoading: Bool = false
    var isPrefetched: Bool = false

    var realmNotificationToken: NotificationToken? = nil


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard query.hasAnyFilledFields() else {
            fatalError("∆ Did not recieve a search query")
        }

        if !isPrefetched {
            UserServices.downloadBills(withQuery: query, completion: {
                result in
                RealmCoordinator.setBillsList(ofType: RealmCoordinator.ListType.mainSearchList, toContain: result)
            })
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        let results = RealmCoordinator.getBillsList(ofType: RealmCoordinator.ListType.mainSearchList)
        realmNotificationToken = results.observe { [weak self] (_)->Void in
            self?.tableView.reloadData()
            self?.isLoading = false
        }

        debugPrint("RealmCoordinator.getBillsListItems(ofType: RealmCoordinator.ListType.mainSearchList).count: \(RealmCoordinator.getBillsListItems(ofType: RealmCoordinator.ListType.mainSearchList).count)")
    }

    deinit {
        realmNotificationToken?.invalidate()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmCoordinator.getBillsListItems(ofType: RealmCoordinator.ListType.mainSearchList).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillTableViewCellId", for: indexPath) as! SearchResultsTableViewCell
        let bill = RealmCoordinator.getBillsListItems(ofType: RealmCoordinator.ListType.mainSearchList)[indexPath.row]
        if bill.comments.characters.count > 0 {
            cell.nameLabel.text = bill.name + " [" + bill.comments + "]"
        } else {
            cell.nameLabel.text = bill.name
        }
        cell.numberLabel.text = bill.number
        return cell
    }

    // MARK: - TableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > RealmCoordinator.getBillsList(ofType: RealmCoordinator.ListType.mainSearchList).bills.count - 15 && !isLoading {
            isLoading = true
            query.pageNumber += 1
            UserServices.downloadBills(withQuery: query, completion: {
                result in
                var bills = RealmCoordinator.getBillsListItems(ofType: RealmCoordinator.ListType.mainSearchList)
                bills.append(contentsOf: result)
                RealmCoordinator.setBillsList(ofType: RealmCoordinator.ListType.mainSearchList, toContain: bills)
            })
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let path = tableView.indexPathForSelectedRow,
            let dest = segue.destination as? BillCardTableViewController {
            dest.bill = RealmCoordinator.getBillsList(ofType: RealmCoordinator.ListType.mainSearchList).bills[path.row]
        }
    }


}
