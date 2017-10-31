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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        loadSavedQuickSearchFields()

        let results = RealmCoordinator.getBillsList(ofType: RealmCoordinatorListType.quickSearchList)

        realmNotificationToken = results.observe { [weak self] (_)->Void in
            self!.tableView.reloadData()
            self!.isLoading = false
        }
    }


    override func viewDidDisappear(_ animated: Bool) {
        UserDefaultsCoordinator.saveQuickSearchFields(name: nameTextField.text ?? "", nr1: number1TextField.text ?? "", nr2: number2TextField.text ?? "")
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
            return RealmCoordinator.getBillsListItems(ofType: RealmCoordinatorListType.quickSearchList).count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpressAddBillTableViewCell", for: indexPath) as! QuickSearchTableViewCell
        let bill = RealmCoordinator.getBillsListItems(ofType: RealmCoordinatorListType.quickSearchList)[indexPath.row]
        if bill.comments.characters.count > 0 {
            cell.billNameLabel.text = bill.name + " [" + bill.comments + "]"
        } else {
            cell.billNameLabel.text = bill.name
        }
        setColorAndNumberForCell(at: indexPath)
        return cell
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bills = RealmCoordinator.getBillsListItems(ofType: RealmCoordinatorListType.quickSearchList)
        RealmCoordinator.updateFavoriteStatusOf(bill: bills[indexPath.row], to: !bills[indexPath.row].favorite)
        { [weak self] in
            self?.setColorAndNumberForCell(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > RealmCoordinator.getBillsList(ofType: RealmCoordinatorListType.quickSearchList).bills.count - 15 && !isLoading {
            isLoading = true
            query.pageNumber += 1
            UserServices.downloadBills(withQuery: query, completion: {
               result in
                var bills = RealmCoordinator.getBillsListItems(ofType: RealmCoordinatorListType.quickSearchList)
                bills.append(contentsOf: result)
                RealmCoordinator.setBillsList(ofType: RealmCoordinatorListType.quickSearchList, toContain: bills)
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
               result in
                RealmCoordinator.setBillsList(ofType: RealmCoordinatorListType.quickSearchList, toContain: result)
            })
            
            self.view.endEditing(true)
        }
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        number1TextField.text = ""
        number2TextField.text = ""
        nameTextField.text = ""
        RealmCoordinator.setBillsList(ofType: RealmCoordinatorListType.quickSearchList, toContain: nil)
    }

    
    // MARK: - Helper functions
    
    private func refillQueryFromTextFields() {
        
        query = BillSearchQuery()
        
        if let num1 = Int(number1TextField.text!), let num2 = Int(number2TextField.text!) {
            if num1 > 0 && num2 > 0 {
                query.number = "\(num1)-\(num2)"
            }
        }
        
        if let name = nameTextField.text {
            if name.characters.count > 0 {
                query.name = name
            }
        }
        
    }
    
    func setColorAndNumberForCell(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? QuickSearchTableViewCell {
            let quickSearchBills = RealmCoordinator.getBillsListItems(ofType: RealmCoordinatorListType.quickSearchList)
            if quickSearchBills[indexPath.row].favorite  {
                cell.billNumberLabel.text = "🎖Добавлен в избранное: 📃\(quickSearchBills[indexPath.row].number)"
                cell.backgroundColor = favoriteAddedColor
            } else {
                cell.billNumberLabel.text = "📃" + quickSearchBills[indexPath.row].number
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
