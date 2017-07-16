//
//  FavoritesTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 09.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {

    var favorites = RealmCoordinator.loadFavoriteBills()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("Total favorites: \(RealmCoordinator.loadFavoriteBills().count)")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 184
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCellId", for: indexPath) as! FavoritesTableViewCell
        cell.nameLabel?.text = favorites[indexPath.row].name
        cell.numberLabel?.text = favorites[indexPath.row].number
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RealmCoordinator.updateFavoriteStatusOf(bill: favorites[indexPath.row], to: false)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }    
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillCardSegue" {
            if let path = tableView.indexPathForSelectedRow,
                let dest = segue.destination as? BillCardTableViewController {
                dest.bill = favorites[path.row]
            }
        }
    }
 

}
