//
//  FavoritesTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 09.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class FavoritesTableViewController: UITableViewController {
    let realm = try? Realm()

    lazy var favoriteBills: Results<FavoriteBill_>? = try? Realm().objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])

    fileprivate var filterString = ""

    var changesObserver: NSObjectProtocol?
    var realmNotificationToken: NotificationToken?
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPushChangesObserver()
        setupRealmNotificationToken()
        setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 184
        if favoriteBills!.count > 0 {
            uninstallEmptyFavoriteViewTemplate()
        }
        tableView.reloadData()
    }

    deinit {
        changesObserver = nil
        realmNotificationToken?.invalidate()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillCardSegue" {
            if let path = tableView.indexPathForSelectedRow,
                let dest = segue.destination as? BillCardTableViewController {
                dest.billNr = favoriteBills![path.row].number
            }
        }
    }

    // MARK: - Additional Views

    func setupEmptyFavoriteViewTemplate () {
        if filterString.count == 0 {
            tableView.backgroundView = UINib(nibName: "FavEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
            tableView.separatorStyle = .none
        }
    }

    func uninstallEmptyFavoriteViewTemplate () {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        let scb = searchController.searchBar
        scb.searchBarStyle = .default
        scb.barTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)

        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            textfield.tintColor = UIColor.black
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9450980392, alpha: 1)
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }

        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }

    // MARK: - Observation

    func setupPushChangesObserver() {
        changesObserver = NotificationCenter.default.addObserver(forName: .remotePushChangesFeteched, object: nil, queue: OperationQueue.main) {
            [weak self] note in
            DispatchQueue.main.async {
                self?.favoriteBills = try? Realm().objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])
                self?.tableView.reloadData()
                if self?.favoriteBills?.count ?? 0 > 0 {
                    self?.uninstallEmptyFavoriteViewTemplate()
                } else {
                    self?.setupEmptyFavoriteViewTemplate()
                }
            }
        }
    }

    func setupRealmNotificationToken() {
        realmNotificationToken = favoriteBills?.observe {
            [weak self] (_) -> Void in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

}

// MARK: - Table view data source

extension FavoritesTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = favoriteBills!.count
        if numberOfRows == 0 {
            setupEmptyFavoriteViewTemplate()
        } else {
            uninstallEmptyFavoriteViewTemplate()
        }
        return numberOfRows
    }

}

// MARK: - Table view delegate

extension FavoritesTableViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCellId", for: indexPath) as! FavoritesTableViewCell
        cell.nameLabel?.text = favoriteBills![indexPath.row].name
        cell.numberLabel?.text = "№ " + favoriteBills![indexPath.row].number
        cell.hasUpdatesLabel?.isHidden = !favoriteBills![indexPath.row].favoriteHasUnseenChanges
        cell.hasUpdatesLabel?.layer.cornerRadius = 10
        cell.hasUpdatesLabel?.layer.masksToBounds = true
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentFavoriteBill = favoriteBills![indexPath.row]
            try? realm?.write {
                currentFavoriteBill.markedToBeRemovedFromFavorites = true
                realm?.add(currentFavoriteBill, update: true)
            }

            try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: currentFavoriteBill.billSyncContainer)

            tableView.deleteRows(at: [indexPath], with: .fade)
            if favoriteBills!.count == 0 {
                setupEmptyFavoriteViewTemplate ()
            }
        }
    }

}

// MARK: - UISearchResultsUpdating

extension FavoritesTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        filterString = searchController.searchBar.text ?? ""

        if filterString.count > 0 {
            favoriteBills = try? Realm().objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"]).filter("name CONTAINS[cd] '\(filterString)' OR comments CONTAINS[cd] '\(filterString)'")
        } else {
            favoriteBills = try? Realm().objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])
        }

        tableView.reloadData()
    }

}

//extension FavoritesTableViewController: UISearchBarDelegate {
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filterString = searchController.searchBar.text ?? ""
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        filterString = ""
//    }
//}
