//
//  DetailsInterfaceController.swift
//  RusBillsWatchApp Extension
//
//  Created by Xan Kraegor on 05.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import WatchKit

class DetailsInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!

    var bill: FavoriteBillForWatchOS?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let context = context as? FavoriteBillForWatchOS {
            bill = context
            setupTable()
        }
    }

    // MARK: - Table

    func setupTable() {
        if let bill = bill {
            table?.setNumberOfRows(7, withRowType: "WatchDetailsTableId")
            let cell0 = table?.rowController(at: 0) as? DetailedInterfaceRowController
            cell0?.nameLabel?.setText(bill.number)
            let cell1 = table?.rowController(at: 1) as? DetailedInterfaceRowController
            cell1?.nameLabel?.setText(bill.name)
            let cell2 = table?.rowController(at: 2) as? DetailedInterfaceRowController
            cell2?.nameLabel?.setText(bill.comments)
            let cell3 = table?.rowController(at: 3) as? DetailedInterfaceRowController
            cell3?.nameLabel?.setText(bill.lastEventDate)
            let cell4 = table?.rowController(at: 4) as? DetailedInterfaceRowController
            cell4?.nameLabel?.setText(bill.lastEventStage)
            let cell5 = table?.rowController(at: 5) as? DetailedInterfaceRowController
            cell5?.nameLabel?.setText(bill.lastEventPhase)
            let cell6 = table?.rowController(at: 6) as? DetailedInterfaceRowController
            cell6?.nameLabel?.setText(bill.lastEventFullDecision)
        } else {
            table?.setNumberOfRows(0, withRowType: "WatchDetailsTableId")
        }
    }
    

}
