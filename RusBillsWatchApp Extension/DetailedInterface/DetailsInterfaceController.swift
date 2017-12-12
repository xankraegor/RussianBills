//
//  DetailsInterfaceController.swift
//  RusBillsWatchApp Extension
//
//  Created by Xan Kraegor on 05.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import WatchKit

class DetailsInterfaceController: WKInterfaceController {

    var bill: FavoriteBillForWatchOS?

    @IBOutlet var numberLabel: WKInterfaceLabel!
    @IBOutlet var nameAndCommentLabel: WKInterfaceLabel!
    @IBOutlet var lastEventLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let context = context as? FavoriteBillForWatchOS {
            bill = context
            setupFields()
        }
    }

    // MARK: - Table

    func setupFields() {
        if let bill = bill {

            numberLabel.setText("№ \(bill.number)")
            if bill.comments.count > 0 {
                nameAndCommentLabel.setText("\(bill.name) [\(bill.comments)]")
            } else {
                nameAndCommentLabel.setText("\(bill.name)")
            }

            var lastEventText = ""

            if bill.lastEventDate.count > 0 {
                lastEventText.append("Дата: \(bill.lastEventDate)")
            }

            if bill.lastEventStage.count > 0, bill.lastEventPhase.count > 0 {
                lastEventText.append("\n\n\(bill.lastEventStage) — \(bill.lastEventPhase)")
            } else if bill.lastEventStage.count > 0 {
                lastEventText.append("\n\n\(bill.lastEventStage)")
            } else if bill.lastEventPhase.count > 0 {
                lastEventText.append("\n\n\(bill.lastEventPhase)")
            }

            if bill.lastEventFullDecision.count > 0 {
                lastEventText.append("\n\nРешение: \(bill.lastEventFullDecision)")
            }

            lastEventLabel.setText(lastEventText)
        }
    }

}
