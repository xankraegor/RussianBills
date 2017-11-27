//
//  QuickSearchTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 12.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class QuickSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    let realm = try? Realm()
    let searchResults = try! Realm().object(ofType: BillsList_.self, forPrimaryKey: BillsListType.quickSearch.rawValue)?.bills
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var number1TextField: UITextField!
    @IBOutlet weak var number2TextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    var query = BillSearchQuery()
    var isLoading = false
    
    let favoriteAddedColor = #colorLiteral(red: 1, green: 0.9601590037, blue: 0.855443418, alpha: 1)
    let notFavoriteColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    var realmNotificationToken: NotificationToken? = nil
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        number1TextField.delegate = self
        number2TextField.delegate = self
        nameTextField.delegate = self
        
        installRealmToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        navigationController?.isToolbarHidden = true
        loadSavedQuickSearchFields()
    }

    override func viewDidDisappear(_ animated: Bool) {
        UserDefaultsCoordinator.saveQuickSearchFields(name: nameTextField.text ?? "", nr1: number1TextField.text ?? "",
                nr2: number2TextField.text ?? "")
    }
    
    deinit {
        realmNotificationToken?.invalidate()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if query.hasAnyFilledFields() {
            return searchResults?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpressAddBillTableViewCell", for: indexPath) as! QuickSearchTableViewCell
        let bill = searchResults![indexPath.row]
        if bill.comments.count > 0 {
            cell.billNameLabel.text = bill.name + " [" + bill.comments + "]"
        } else {
            cell.billNameLabel.text = bill.name
        }
        setColorAndNumberForCell(at: indexPath)
        return cell
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bill = searchResults![indexPath.row]
        try? realm?.write {
            if let existingFavoriteBill = realm?.object(ofType: FavoriteBill_.self, forPrimaryKey: bill.number) {
                realm?.delete(existingFavoriteBill)
            } else {
                let newFavoriteBill = FavoriteBill_(fromBill: bill)
                realm?.add(newFavoriteBill, update: true)
            }
        }
        setColorAndNumberForCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let existingSearchResults = searchResults, indexPath.row > existingSearchResults.count - 15 && !isLoading {
            isLoading = true
            query.pageNumber += 1
            UserServices.downloadBills(withQuery: query, completion: {
                [weak self] resultBills in
                let realm = try? Realm()
                let existingList = realm?.object(ofType: BillsList_.self,
                        forPrimaryKey: BillsListType.quickSearch.rawValue) ?? BillsList_(withName: .quickSearch)
                try? realm?.write {
                    existingList.bills.append(objectsIn: resultBills)
                    realm?.add(existingList, update: true)
                }
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            })
        }
    }


    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        refillQueryFromTextFields()
        if query.hasAnyFilledFields() {
            UserServices.downloadBills(withQuery: query, completion: {
               resultBills in
                let realm = try? Realm()
                let list = realm?.object(ofType: BillsList_.self,
                        forPrimaryKey: BillsListType.quickSearch.rawValue) ?? BillsList_(withName: .quickSearch)
                try? realm?.write {
                    list.bills.removeAll()
                    list.bills.append(objectsIn: resultBills)
                }
            })
            self.view.endEditing(true)
        }
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        number1TextField.text = ""
        number2TextField.text = ""
        nameTextField.text = ""
        try? realm?.write {
            realm?.object(ofType: BillsList_.self, forPrimaryKey: BillsListType.quickSearch.rawValue)?.bills.removeAll()
        }
    }

    
    // MARK: - Helper functions

    private func installRealmToken() {
        realmNotificationToken = searchResults?.observe {
            [weak self] (changes: RealmCollectionChange) in

            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    private func refillQueryFromTextFields() {
        
        query = BillSearchQuery()
        
        if let num1 = Int(number1TextField.text!), let num2 = Int(number2TextField.text!) {
            if num1 > 0 && num2 > 0 {
                query.number = "\(num1)-\(num2)"
            }
        }
        
        if let name = nameTextField.text {
            if name.count > 0 {
                query.name = name
            }
        }
    }
    
    func setColorAndNumberForCell(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? QuickSearchTableViewCell {
            if searchResults![indexPath.row].favorite  {
                cell.billNumberLabel.text = "🎖Добавлен в избранное: 📃\(searchResults![indexPath.row].number)"
                cell.backgroundColor = favoriteAddedColor
            } else {
                cell.billNumberLabel.text = "📃" + searchResults![indexPath.row].number
                cell.backgroundColor = notFavoriteColor
            }
        }
    }
    
    func loadSavedQuickSearchFields() {
        let savedTextFields = UserDefaultsCoordinator.getQuickSearchFields()
        self.nameTextField.text = savedTextFields.name
        self.number1TextField.text = savedTextFields.nr1
        self.number2TextField.text = savedTextFields.nr2
    }
    
}
