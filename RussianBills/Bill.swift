//
//  Bill.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Законопроект
final class Bill_: Object, InitializableWithJson {
    dynamic var id: Int = 0
    dynamic var lawType: LawType = LawType.federalLaw
    dynamic var number: String = ""
    dynamic var name: String = ""
    dynamic var comments: String = ""
    dynamic var introductionDate: String = ""
    dynamic var url: String = ""
    dynamic var transcriptUrl: String = ""
    dynamic var favorite: Bool = false

//    var lastEvent: [String : String]
//    var subject: [String: String]
//
    //    var comitteeResponsible: Comittee_
    //    var comitteeProfile: [Comittee_]
    //    var comitteeCoexecutor: [Comittee_]

    convenience  init(withJson json: JSON, favoriteMark: Bool = false) {
        self.init(withJson: json)
        favorite = favoriteMark
    }

    internal convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        lawType = LawType(rawValue: json["type"]["id"].intValue)!
        name = json["name"].stringValue
        number = json["number"].stringValue
        introductionDate = json["introductionDate"].stringValue
        url = json["url"].stringValue
        transcriptUrl = json["transcriptUrl"].stringValue
    }

    override static func primaryKey() -> String {
        return "id"
    }
}
