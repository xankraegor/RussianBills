//
//  InterfaceController.swift
//  RusBillsWatchApp Extension
//
//  Created by Xan Kraegor on 04.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import WatchKit

class MainInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!

    var favoriteBills: [FavoriteBillForWatchOS] {
        return Array(mockupBills.values)
    }

    /// Debug mockup favorite bills
    let mockupBills : [String : FavoriteBillForWatchOS] = [
        "1": FavoriteBillForWatchOS(withNumber: "12345-6", name: "О внесении изменений в НК РФ", comments: "", lastEventDate: "12.11.2017", lastEventStage: "Стадия 1", lastEventPhase: "Фаза1", lastEventFullDescription: "Рекомедовать ко 2 чтению"),
        "2": FavoriteBillForWatchOS(withNumber: "234566-7", name: "О бюджете РФ на 2018", comments: "", lastEventDate: "12.11.2017", lastEventStage: "Стадия 2", lastEventPhase: "Фаза2", lastEventFullDescription: "Рекомедовать ко 2 чтению"),
        "3": FavoriteBillForWatchOS(withNumber: "567890-7", name: "О бюджете Пенсионного Фонда РФ на 2018", comments: "", lastEventDate: "09.10.2017", lastEventStage: "Стадия 3", lastEventPhase: "Фаза3", lastEventFullDescription: "Рекомедовать ко 2 чтению")
    ]
    

    // MARK: - Life cycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - Table

    func setupTable() {
        table?.setNumberOfRows(favoriteBills.count, withRowType: "mainInterfaceRowController")
        print("favoriteBills : \(favoriteBills.count)")
        for index in 0..<favoriteBills.count {
            guard let controller = table.rowController(at: index) as? MainInterfaceRowController else { continue }
            controller.nameLabel.setText("\(favoriteBills[index].number) \(favoriteBills[index].name)")
        }
    }

//    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
//        let bill = favoriteBills[rowIndex]
//        presentController(withName: "detailsInterfaceController", context: bill)
//    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return favoriteBills[rowIndex]
    }

}
