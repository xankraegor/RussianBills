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
    var realmNotificationToken: NotificationToken?
    let searchResults: BillsList_? = try! Realm().object(ofType: BillsList_.self, forPrimaryKey: BillsListType.mainSearch.rawValue)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let results = realm?.object(ofType: BillsList_.self, forPrimaryKey: BillsListType.mainSearch.rawValue) ?? BillsList_(withName: .mainSearch, totalCount: 0)

        realmNotificationToken = results.observe { [weak self] (_) -> Void in
            self?.navigationItem.title = "Найдено: \(self?.searchResults?.totalCount ?? 0)"
            self?.tableView.reloadData()
            self?.isLoading = false
        }

        if !isPrefetched {
            navigationItem.title = "Поиск..."
            UserServices.downloadBills(withQuery: query, completion: {
                resultBills, totalCount in
                let realm = try? Realm()
                let newList = BillsList_(withName: BillsListType.mainSearch, totalCount: totalCount)
                newList.bills.append(objectsIn: resultBills)
                try? realm?.write {
                    realm?.add(newList, update: true)
                }
            })
        } else {
            navigationItem.title = "Найдено: \(searchResults?.totalCount ?? 0)"
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
        if !query.hasAnyFieldsFilled {
            query = BillSearchQuery(withRegistrationEndDate: Date())
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
        return searchResults?.bills.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillTableViewCellId", for: indexPath) as! SearchResultsTableViewCell
        let bill = searchResults!.bills[indexPath.row]
        if bill.comments.count > 0 {
            cell.nameLabel?.text = "\(bill.name) [\(bill.comments)]"
        } else {
            cell.nameLabel?.text = bill.name
        }

        if bill.favorite {
            cell.isFavoriteLabel?.text = "Отслеживается"
        } else {
            cell.isFavoriteLabel?.text = " "
        }

        cell.numberLabel?.text = " № \(bill.number)"

        return cell
    }

    // MARK: - TableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let foundBills = searchResults, foundBills.bills.count < foundBills.totalCount else {
            return
        }
        if !isLoading && indexPath.row > foundBills.bills.count - 19 {
            isLoading = true
            query.pageNumber += 1
            UserServices.downloadBills(withQuery: query, completion: { resultBills, totalCount in
                let realm = try? Realm()
                let existingList = realm?.object(ofType: BillsList_.self, forPrimaryKey: BillsListType.mainSearch.rawValue) ??
                        BillsList_(withName: .mainSearch, totalCount: totalCount)
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
            dest.billNr = results.bills[path.row].number
        }
    }

}
