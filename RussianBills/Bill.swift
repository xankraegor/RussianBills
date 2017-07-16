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
    
    dynamic var lastEventStageDesription: String = ""
    dynamic var lastEventPhaseDescription: String = ""
    dynamic var lastEventSolutionDescription: String = ""
    dynamic var lastEventDate: String = ""
    dynamic var lastEventDocumentName: String = ""
    dynamic var lastEventDocumentType: String = ""

    dynamic var comitteeResponsible: [Comittee_] = []
    dynamic var comitteeProfile: [Comittee_] = []
    dynamic var comitteeCoexecutor: [Comittee_] = []

    convenience  init(withJson json: JSON, favoriteMark: Bool = false) {
        self.init(withJson: json)
        favorite = favoriteMark
    }

    internal convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        lawType = LawType(rawValue: json["type"]["id"].intValue)!
        name = json["name"].stringValue
        comments = json["comments"].stringValue
        number = json["number"].stringValue
        introductionDate = json["introductionDate"].stringValue
        url = json["url"].stringValue
        transcriptUrl = json["transcriptUrl"].stringValue
        
        let comitteeResponsibleId = json["committees"]["responsible"]["name"].stringValue
        if let comRes = 


        let profileComs = json["committees"]["profile"].arrayValue
        for com in profileComs {
            comitteeProfile.append(com["name"].stringValue)
        }
        
        let coexecs = json["committees"]["soexecutor"].arrayValue
        for coex in coexecs {
            comitteeCoexecutor.append(coex["name"].stringValue)
        }

        
        lastEventStageDesription = json["lastEvent"]["stage"]["name"].stringValue
        lastEventPhaseDescription = json["lastEvent"]["phase"]["name"].stringValue
        lastEventSolutionDescription = json["lastEvent"]["solution"].stringValue
        lastEventDate = json["lastEvent"]["date"].stringValue
        lastEventDocumentName = json["lastEvent"]["document"]["name"].stringValue
        lastEventDocumentType = json["lastEvent"]["document"]["type"].stringValue
    }

    override static func primaryKey() -> String {
        return "id"
    }
    
    func generateFullSolutionDescription() -> String {
        var output = lastEventSolutionDescription + "\n"
        output += lastEventDocumentType.characters.count > 0 ? lastEventDocumentType + " " : ""
        output += lastEventDocumentName.characters.count > 0 ? lastEventDocumentName + " " : ""
        output += lastEventDate.isoDateToReadableDate() ?? ""
        return output
    }
}
