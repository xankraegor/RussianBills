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

    lazy var updatedBills = {
        return realm?.objects(FavoriteBill_.self).filter(FavoritesFilters.both.rawValue)
    }()

    lazy var favoriteBills = {
        return realm?.objects(FavoriteBill_.self).filter(FavoritesFilters.notMarkedToBeRemoved.rawValue)
                .sorted(by: [SortDescriptor(keyPath: "favoriteHasUnseenChanges", ascending: false), "number"])
    }()


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
            preferredContentSize = CGSize(width: 0.0, height: 500.0)
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

        let totalCount = favoriteBills?.filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).count ?? 0
        let updatedCount = updatedBills?.count ?? 0

        let updatedDate: Date?
        if let fb = favoriteBills {
            updatedDate = Array(fb).flatMap {
                $0.bill?.updated
            }.min()
        } else {
            updatedDate = nil
        }

        var updatedDateString: String
        if totalCount > 0, let date = updatedDate {
            updatedDateString = "(обновл. \(dateFormatter.string(from: date)))"
        } else if totalCount > 0, let date = favoriteBills?.sorted(by: [SortDescriptor(keyPath: "favoriteUpdatedTimestamp", ascending: false)]).first?.favoriteUpdatedTimestamp, date > Date.distantPast {
            updatedDateString = "(обновл. \(dateFormatter.string(from: date)))"
        } else {
            updatedDateString = "(не обновлялось)"
        }

        let outputSring = "Новых: \(updatedCount) из \(totalCount) \(updatedDateString)"
        updatesButton?.setTitle(outputSring, for: UIControlState.normal)
    }

    @IBAction func updatesButtonPressed(_ sender: Any) {
        let url = URL(string: "rusBills://favorites")!
        extensionContext?.open(url, completionHandler: nil)
    }

}

extension TodayViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (favoriteBills?.count ?? 0) > 5 ? (5) : (favoriteBills?.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActualFavoriteBillsCellId", for: indexPath)
        let favoriteBill = favoriteBills![indexPath.row]
        cell.textLabel?.text = "№ \(favoriteBill.number) \(favoriteBill.name)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let bill = favoriteBill.bill {
            cell.detailTextLabel?.text = "Последнее событие \(bill.lastEventDate.isoDateToReadableDate())"
        }
        return cell
    }

}

extension TodayViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let number = favoriteBills?[indexPath.row].number,
              number.count > 0 else {
            return
        }
        let url = URL(string: "rusBills://favorites")!.appendingPathComponent(number)

        extensionContext?.open(url, completionHandler: nil)
    }

}
