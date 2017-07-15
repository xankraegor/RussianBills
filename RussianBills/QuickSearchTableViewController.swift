//
//  QuickSearchTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 12.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

class QuickSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    typealias VoidToVoid = (() -> Void)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var number1TextField: UITextField!
    @IBOutlet weak var number2TextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    var query = BillSearchQuery()
    var loadedBills = [Bill_]()

    var notificationToken: NotificationToken?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    deinit {
        notificationToken?.stop()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if query.hasAnyFilledFields() {
            return loadedBills.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpressAddBillTableViewCell", for: indexPath) as! QuickSearchTableViewCell
        let bill = loadedBills[indexPath.row]
        cell.billNameLabel.text = bill.name
        cell.billNumberLabel.text = bill.number
        return cell
    }

    // MARK: - TableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RealmCoordinator.updateFavoriteStatusOf(bill: loadedBills[indexPath.row], to: true)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func searchButtonPressed(_ sender: UIButton) {

        refillQueryFromTextFields()

        if query.hasAnyFilledFields() {
            notificationToken = produceNotificationTokenForBill(havingFilter: query.produceFilter(),
                                                                completion: { (_) in
                reloadTableUsingNewData()
            })

            debugPrint("searchButtonPressed: Query got filled fields")

            UserServices.downloadBills(withQuery: query, completion: { result in
                self.loadedBills = result
                print(self.loadedBills.count)
            })

        } else {
            debugPrint("searchButtonPressed: Query has no filled fields")
        }
    }

    // MARK: - Helper functions

    private func reloadTableUsingNewData() {
        debugPrint("reloadTableUsingNewData")

        tableView.reloadData()

    }

    private func refillQueryFromTextFields() {

        query = BillSearchQuery()

        if let num1 = Int(number1TextField.text!), let num2 = Int(number2TextField.text!) {
            if num1 > 0 && num2 > 0 {
                query.number = "\(num1)-\(num2)"
                debugPrint("query.number = \(String(describing: query.number))")
            }
        }

        if let name = nameTextField.text {
            if name.characters.count > 0 {
                query.name = name
                debugPrint("query.name = \(String(describing: query.name))")
            }
        }

    }

    // MARK: - Realm Notifications
    func produceNotificationTokenForBill(havingFilter: String?, completion: VoidToVoid) ->
        NotificationToken? {
            if let realm = try? Realm() {
                let results = realm.objects(Bill_.self)
                return results.addNotificationBlock { [weak self] _ in
                    self?.reloadTableUsingNewData()
                }
            } else {
                return nil
            }
    }

}
