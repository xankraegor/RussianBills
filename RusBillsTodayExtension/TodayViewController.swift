//
//  TodayViewController.swift
//  RusBillsTodayExtension
//
//  Created by Xan Kraegor on 28.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var updatesButton: UIButton?
    @IBOutlet weak var tableView: UITableView?

    lazy var realm: Realm? = {
        var config = Realm.Configuration()
        config.fileURL = FilesManager.defaultRealmPath()
        Realm.Configuration.defaultConfiguration = config
        let realm = try? Realm()
        return realm
    }()

    lazy var favoriteBillsFilteredAndSorted = realm?.objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM в H:mm"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 30
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        setupView()
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = maxSize // CGSize(width: 0.0, height: 300.0)
            tableView?.isHidden = false
        } else {
            preferredContentSize = maxSize
            tableView?.isHidden = true
        }
    }

    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        setupView()
        completionHandler(NCUpdateResult.newData)
    }

    func setupView() {
        tableView?.reloadData()
        let favoriteBills = realm?.objects(FavoriteBill_.self)
        let totalCount = favoriteBills?.filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).count ?? 0
        let updatedCount =  favoriteBills?.filter(FavoritesFilters.both.rawValue).count ?? 0

        let updatedDate = UserDefaultsCoordinator.favorites.updatedAt()
        var updatedDateString: String

        if totalCount > 0, let date = updatedDate {
            updatedDateString = "(обновл. \(dateFormatter.string(from: date)))"
        } else if totalCount > 0, let date = favoriteBillsFilteredAndSorted?.sorted(by: [SortDescriptor(keyPath: "favoriteUpdatedTimestamp", ascending: false)]).first?.favoriteUpdatedTimestamp, date > Date.distantPast {
            updatedDateString = "(обновл. \(dateFormatter.string(from: date)))"
        } else {
            updatedDateString = "(не обновлялось)"
        }

        let outputSring = "Новых: \(updatedCount) из \(totalCount) \(updatedDateString)"
        updatesButton?.setTitle(outputSring, for: UIControlState.normal)
    }

    @IBAction func updatesButtonPressed(_ sender: Any) {
        let url = URL(string: "russianBills://favorites")!
        extensionContext?.open(url, completionHandler: nil)
    }

}

extension TodayViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteBillsFilteredAndSorted!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActualFavoriteBillsCellId", for: indexPath)
        let favoriteBill = favoriteBillsFilteredAndSorted![indexPath.row]
        cell.textLabel?.text = "№\(favoriteBill.number) \(favoriteBill.name)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let bill = favoriteBill.bill {
            cell.detailTextLabel?.text = "Обновлен \(bill.lastEventDate)"
        }
        return cell
    }

}

extension TodayViewController: UITableViewDelegate {

}
