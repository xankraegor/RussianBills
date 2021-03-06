//
//  InterfaceController.swift
//  RusBillsWatchApp Extension
//
//  Created by Xan Kraegor on 04.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import WatchKit
import WatchConnectivity

class MainInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!

    var favoriteBills: [FavoriteBillForWatchOS]? = nil {
        didSet {
            DispatchQueue.main.async {
                self.setupTable()
            }
        }
    }

    let notifCenter = NotificationCenter.default

    // MARK: - Life cycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupTable()

        notifCenter.addObserver(forName: Notification.Name(rawValue: "watchReceivedUpdatedData"), object: nil, queue: OperationQueue.main) {
            [weak self] (notification) in
            if let favs = notification.userInfo as? [String: [FavoriteBillForWatchOS]], let values = favs["favoriteBills"] {
                DispatchQueue.main.async {
                    self?.favoriteBills = values
                }
            } else {
                assertionFailure("∆ Can't unwrap notification.userInfo as? [String: [FavoriteBillForWatchOS]]")
            }
        }

        if favoriteBills == nil {
            favoriteBills = WatchSessionManager.shared.favoriteBills
        }
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    // MARK: - Table

    func setupTable() {
        table?.setNumberOfRows(favoriteBills?.count ?? 0, withRowType: "mainInterfaceRowController")

        for index in 0..<(favoriteBills?.count ?? 0) {
            guard let controller = table.rowController(at: index) as? MainInterfaceRowController else {
                continue
            }
            controller.nameLabel.setText("\(favoriteBills?[index].number ?? "") \(favoriteBills?[index].name ?? "")")
        }
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return favoriteBills?[rowIndex] ?? 0
    }

}
