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

    @IBOutlet weak var updatesButton: UIButton!

    lazy var realm: Realm? = {
        var config = Realm.Configuration()
        config.fileURL = FilesManager.defaultRealmPath()
        Realm.Configuration.defaultConfiguration = config
        let realm = try? Realm()
        return realm
    }()

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM в H:mm"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        setupView()
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }

    func setupView() {
        let favoriteBills = realm?.objects(FavoriteBill_.self)
        let totalCount = favoriteBills?.filter(FavoritesFilters.notMarkedToBeRemoved.rawValue).count ?? 0
        let updatedCount =  favoriteBills?.filter(FavoritesFilters.both.rawValue).count ?? 0

        let updatedDate = UserDefaultsCoordinator.favorites.updatedAt()
        var updatedDateString: String
        if let date = updatedDate {
            updatedDateString = "(обновл. \(dateFormatter.string(from: date)))"
        } else {
            updatedDateString = "(не обновлялось)"
        }

        let outputSring = "Новых: \(updatedCount) из \(totalCount) \(updatedDateString)"

        updatesButton.setTitle(outputSring, for: UIControlState.normal)
    }

    @IBAction func updatesButtonPressed(_ sender: Any) {
        let url = URL(string: "RussianBills://")!
        extensionContext?.open(url, completionHandler: nil)
    }

    
}
