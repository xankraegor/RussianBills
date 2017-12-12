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

    #endif

    init?(withDictionary dict: [String: String]) {
        guard let existingNumber = dict["number"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            let existingName = dict["name"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            existingName.count > 0, existingNumber.count > 0 else { return nil }
        self.number = existingNumber
        self.name = existingName
        self.comments = dict["comments"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        self.lastEventDate = dict["lastEventDate"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        self.lastEventStage = dict["lastEventStage"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        self.lastEventPhase = dict["lastEventPhase"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        self.lastEventFullDecision = dict["lastEventFullDecision"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
    }

    func dictionary()->Dictionary<String, String> {
        return [
            "number" : self.number,
            "name" : self.name,
            "comments" : self.comments,
            "lastEventDate" : self.lastEventDate,
            "lastEventStage" : self.lastEventStage,
            "lastEventPhase" : self.lastEventPhase,
            "lastEventFullDecision" : self.lastEventFullDecision
        ]
    }

}
