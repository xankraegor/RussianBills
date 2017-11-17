//
//  SearchResultsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 19.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class SearchResultsTableViewController: UITableViewController {
    let realm = try? Realm()
    var query = BillSearchQuery()
    var isLoading: Bool = false
    var isPrefetched: Bool = false
    var realmNotificationToken: NotificationToken? = nil
    let searchResults = try! Realm().object(ofType: BillsList_.self, forPrimaryKey: BillsListType.mainSearch.rawValue)?.bills


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard query.hasAnyFilledFields() else {
            fatalError("∆ Did not recieve a search query")
        }

        if !isPrefetched {
            UserServices.downloadBills(withQuery: query, completion: {
                resultBills in
                let realm = try? Realm()
                let newList = BillsList_(withName: BillsListType.mainSearch)
                newList.bills.append(objectsIn: resultBills)
                try? realm?.write {realm?.add(newList, update: true)}
            })
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let results = realm?.object(ofType: BillsList_.self, forPrimaryKey: BillsListType.mainSearch.rawValue) ?? BillsList_(withName: .mainSearch)
        
        realmNotificationToken = results.observe { [weak self] (_)->Void in
            self?.tableView.reloadData()
            self?.isLoading = false
        }
    }

    deinit {
        realmNotificationToken?.invalidate()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillTableViewCellId", for: indexPath) as! SearchResultsTableViewCell
        let bill = searchResults![indexPath.row]
        if bill.comments.count > 0 {
            cell.nameLabel.text = bill.name + " [" + bill.comments + "]"
        } else {
            cell.nameLabel.text = bill.name
        }
        cell.numberLabel.text = bill.number
        return cell
    }

    // MARK: - TableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let existingSearchResults = searchResults, indexPath.row > existingSearchResults.count - 15 && !isLoading {
            isLoading = true
            query.pageNumber += 1
            UserServices.downloadBills(withQuery: query, completion: { resultBills in
                let realm = try? Realm()
                let existingList = realm?.object(ofType: BillsList_.self, forPrimaryKey: BillsListType.mainSearch.rawValue) ?? BillsList_(withName: .mainSearch)
                try? realm?.write {
                    existingList.bills.append(objectsIn: resultBills)
                    realm?.add(existingList, update: true)
                }
            })
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let path = tableView.indexPathForSelectedRow, let results = searchResults,
            let dest = segue.destination as? BillCardTableViewController {
            dest.billNr = results[path.row].number
        }
    }


}
