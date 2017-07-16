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
    
    dynamic var lastEventStage = Stage_()
    dynamic var lastEventPhase = Phase_()
    dynamic var lastEventSolutionDescription: String = ""
    dynamic var lastEventDate: String = ""
    dynamic var lastEventDocumentName: String = ""
    dynamic var lastEventDocumentType: String = ""

    dynamic var comitteeResponsible = Comittee_()
    dynamic var comitteeProfile = List<Comittee_>()
    dynamic var comitteeCoexecutor = List<Comittee_>()

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
        
        // Responsible committee
        let comitteeId = json["committees"]["responsible"]["id"].stringValue
        if let committeeById = RealmCoordinator.loadObject(
Comittee_, byId: comitteeId) {
            comitteeResponsible = committeeById
        } else {
            var committee = Comittee_()
            committee.id = comitteeResponsibleId
            committee.name = json["committees"]["responsible"]["name"].stringValue
            committee.isCurrent = json["committees"]["responsible"]["isCurrent"].boolValue
            committee.startDate = json["committees"]["responsible"]["startDate"].stringValue
            committee.stopDate = json["committees"]["responsible"]["stopDate"].stringValue
            
            RealmCoordinator.save(object: committee)
            comitteeResponsible = committee
        }
        
        // Profile committees
        let profileComs = json["committees"]["profile"].arrayValue
        
        for com in profileComs {
            let comitteeId = com["id"].stringValue
        if let committeeById = RealmCoordinator.loadObject(
Comittee_, byId: comitteeId) {
            comitteeResponsible.append(committeeById)
        } else {
            var committee = Comittee_()
            committee.id = comitteeResponsibleId
            committee.name = com["name"].stringValue
            committee.isCurrent = com["isCurrent"].boolValue
            committee.startDate = com["startDate"].stringValue
            committee.stopDate = com["stopDate"].stringValue
            
             RealmCoordinator.save(collection: [committee])
            comitteeProfile.append(committee)
        }
        }
        
        // Coexexutor committees
        let coexecs = json["committees"]["soexecutor"].arrayValue
        
        for com in coexecs {
            let comitteeId = com["id"].stringValue
            if let committeeById = RealmCoordinator.loadObject(
Comittee_, byId: comitteeId) {
            comitteeResponsible.append(committeeById)
        } else {
            var committee = Comittee_()
            committee.id = comitteeResponsibleId
            committee.name = com["name"].stringValue
            committee.isCurrent = com["isCurrent"].boolValue
            committee.startDate = com["startDate"].stringValue
            committee.stopDate = com["stopDate"].stringValue
            
             RealmCoordinator.save(collection: [committee])
            comitteeCoexecutor.append(committee)
        }
        }
        
        // Stage
        let lastEventStageId = json["lastEvent"]["stage"]["id"].intValue
        if let lastStage = RealmCoordinator.loadObject(
Stage_, byId: lastEventStageId) {
             lastEventStage = lastStage
        } else {
             var lastStage = Stage_()
             lastStage.id = lastEventStageId
             lastStage.name = json["lastEvent"]["stage"]["name"].stringValue
             
             RealmCoordinator.save(object: lastStage)
             lastEventStage = lastStage
        }
        
        // Phase
         let lastEventPhaseId = json["lastEvent"]["phase"]["id"].intValue
        if let lastPhase = RealmCoordinator.loadObject(
Stage_, byId: lastEventPhaseId) {
             lastEventPhase = lastPhase
        } else {
             var lastPhase = Phase_()
             lastPhase.id = lastEventPhaseId
             lastPhase.name = json["lastEvent"]["phase"]["name"].stringValue
             
            RealmCoordinator.save(object: lastPhase)
            lastEventPhase = lastPhase
        }
        
        // Solution
        lastEventSolutionDescription = json["lastEvent"]["solution"].stringValue
        lastEventDate = json["lastEvent"]["date"].stringValue
        lastEventDocumentName = json["lastEvent"]["document"]["name"].stringValue
        lastEventDocumentType = json["lastEvent"]["document"]["type"].stringValue
    }

    override static func primaryKey() -> String {
        return "id"
    }
    
    // MARK: - Helper functions
    func generateFullSolutionDescription() -> String {
        var output = lastEventSolutionDescription + "\n"
        output += lastEventDocumentType.characters.count > 0 ? lastEventDocumentType + " " : ""
        output += lastEventDocumentName.characters.count > 0 ? lastEventDocumentName + " " : ""
        output += lastEventDate.isoDateToReadableDate() ?? ""
        return output
    }
}
