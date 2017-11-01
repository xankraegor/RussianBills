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
    let favoriteBills = try? Realm().objects(Bill_.self).filter("favorite == true")
    
    // MARK: - Life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 184
        if favoriteBills!.count > 0 {
            uninstallEmptyFavoriteViewTemplate()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = favoriteBills!.count
        if numberOfRows == 0 {
            setupEmptyFavoriteViewTemplate ()
        }
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCellId", for: indexPath) as! FavoritesTableViewCell
        cell.nameLabel?.text = favoriteBills![indexPath.row].name
        cell.numberLabel?.text = "📃" + favoriteBills![indexPath.row].number
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentFavoriteBill = favoriteBills![indexPath.row]
            try? realm?.write { currentFavoriteBill.favorite = false }
            tableView.deleteRows(at: [indexPath], with: .fade)
            if favoriteBills!.count == 0 {
                setupEmptyFavoriteViewTemplate ()
            }
        }
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
        tableView.backgroundView = UINib(nibName: "FavEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
        tableView.separatorStyle = .none
    }

    func uninstallEmptyFavoriteViewTemplate () {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }

}
