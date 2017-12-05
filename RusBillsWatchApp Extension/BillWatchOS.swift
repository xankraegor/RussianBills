//
//  BillWatchOS.swift
//  RusBillsWatchApp Extension
//
//  Created by Xan Kraegor on 05.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

#if os(iOS)
    import RealmSwift
#endif

public final class FavoriteBillForWatchOS {
    var number: String
    var name: String
    var comments: String

    var lastEventDate: String
    var lastEventStage: String
    var lastEventPhase: String
    var lastEventFullDecision: String

    #if os(iOS)

    init(withFavoriteBill fav: FavoriteBill_) {
        self.number = fav.number
        self.name = fav.name
        self.comments = fav.comments

        self.lastEventDate = fav.bill?.generateLastEventDateDescription() ?? ""
        self.lastEventStage = fav.bill?.lastEventStage?.name ?? ""
        self.lastEventPhase = fav.bill?.lastEventPhase?.name ?? ""
        self.lastEventFullDecision = fav.bill?.generateSolutionDescription() ?? ""
    }

    #else

    init(withNumber: String, name: String, comments: String, lastEventDate: String, lastEventStage: String,
         lastEventPhase: String, lastEventFullDescription: String) {
        self.number = withNumber
        self.name = name
        self.comments = comments

        self.lastEventDate = lastEventDate
        self.lastEventStage = lastEventStage
        self.lastEventPhase = lastEventPhase
        self.lastEventFullDecision = lastEventFullDescription
    }

    #endif

}
