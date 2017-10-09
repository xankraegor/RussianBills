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

    @objc dynamic var id: Int = 0
    @objc dynamic var lawType: LawType = LawType.federalLaw
    @objc dynamic var number: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var comments: String = ""
    @objc dynamic var introductionDate: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var transcriptUrl: String = ""
    @objc dynamic var favorite: Bool = false

    /* Introduced by: */
    let factions = List<Factions_>()
    let deputees = List<Deputy_>()
    let federalSubjects = List<FederalSubject_>()
    let regionalSubjects = List<RegionalSubject_>()
    /*
     Duma deputies and members of the Federal Council, ferderal and regional subjects of legislative initiative
     */

    @objc dynamic var lastEventStage: Stage_?
    @objc dynamic var lastEventPhase: Phase_?

    @objc dynamic var lastEventSolutionDescription: String = ""
    @objc dynamic var lastEventDate: String = ""
    @objc dynamic var lastEventDocumentName: String = ""
    @objc dynamic var lastEventDocumentType: String = ""

    @objc dynamic var comitteeResponsible: Comittee_?
    let comitteeProfile = List<Comittee_>()
    let comitteeCoexecutor = List<Comittee_>()

    convenience  init(withJson json: JSON, favoriteMark: Bool = false) {
        self.init(withJson: json)
        favorite = favoriteMark
    }

    internal convenience required init(withJson json: JSON) {
        self.init()

        // Basic variables ==============================================================================
        id = json["id"].intValue
        lawType = LawType(rawValue: json["type"]["id"].intValue)!
        name = json["name"].stringValue
        comments = json["comments"].stringValue
        number = json["number"].stringValue
        introductionDate = json["introductionDate"].stringValue
        url = json["url"].stringValue
        transcriptUrl = json["transcriptUrl"].stringValue

        // Factions ==============================================================================
        let factions = json["subject"]["factions"].arrayValue
        
        for fac in factions {
            let facId = fac["id"].intValue
            if let faction = RealmCoordinator.loadObject(Factions_.self, byId: facId) {
                self.factions.append(faction)
            } else {
                let faction = Factions_()
                faction.id = facId
                faction.name = fac["name"].stringValue
                RealmCoordinator.save(object: faction)
                self.factions.append(faction)
            }
        }

        // Deputies ==============================================================================
        let deputies = json["subject"]["deputies"].arrayValue

        for dep in deputies {
            let depId = dep["id"].intValue
            if let deputy = RealmCoordinator.loadObject(Deputy_.self, byId: depId) {
                deputees.append(deputy)
            } else {
                let deputy = Deputy_()
                deputy.id = depId
                deputy.name = dep["name"].stringValue
                deputy.isCurrent = dep["isCurrent"].boolValue
                deputy.position = dep["position"].stringValue

                RealmCoordinator.save(object: deputy)
                deputees.append(deputy)
            }
        }

        // Other subjects ==============================================================================
        let subjects = json["subject"]["departments"].arrayValue

        for sub in subjects {
            let subId = sub["id"].intValue

            if let fedSub = RealmCoordinator.loadObject(FederalSubject_.self, byId: subId) {
                RealmCoordinator.save(object: fedSub)
                federalSubjects.append(fedSub)
            } else if let regSub = RealmCoordinator.loadObject(RegionalSubject_.self, byId: subId) {
                RealmCoordinator.save(object: regSub)
                regionalSubjects.append(regSub)
            } else {
                debugPrint("∆ FED/REG SUBJECT NOT FOUND IN DB: \n\(sub)\n===================================================")
            }
        }

        // Responsible committee ==============================================================================
        let comitteeId = json["committees"]["responsible"]["id"].intValue
        if let committeeById = RealmCoordinator.loadObject(Comittee_.self, byId: comitteeId) {
            comitteeResponsible = committeeById
        } else {
            let committee = Comittee_()
            committee.id = comitteeId
            committee.name = json["committees"]["responsible"]["name"].stringValue
            committee.isCurrent = json["committees"]["responsible"]["isCurrent"].boolValue
            committee.startDate = json["committees"]["responsible"]["startDate"].stringValue
            committee.stopDate = json["committees"]["responsible"]["stopDate"].stringValue

            RealmCoordinator.save(object: committee)
            comitteeResponsible = committee
        }

        // Profile committees ==============================================================================
        let profileComs = json["committees"]["profile"].arrayValue

        for com in profileComs {
            let comitteeId = com["id"].intValue
            if let committeeById = RealmCoordinator.loadObject(Comittee_.self, byId: comitteeId) {
                comitteeProfile.append(committeeById)
            } else {
                let committee = Comittee_()
                committee.id = comitteeId
                committee.name = com["name"].stringValue
                committee.isCurrent = com["isCurrent"].boolValue
                committee.startDate = com["startDate"].stringValue
                committee.stopDate = com["stopDate"].stringValue

                RealmCoordinator.save(collection: [committee])
                comitteeProfile.append(committee)
            }
        }

        // Coexexutor committees ==============================================================================
        let coexecs = json["committees"]["soexecutor"].arrayValue

        for com in coexecs {
            let comitteeId = com["id"].intValue
            if let committee = RealmCoordinator.loadObject(Comittee_.self, byId: comitteeId) {
                comitteeCoexecutor.append(committee)
            } else {
                let committee = Comittee_()
                committee.id = comitteeId
                committee.name = com["name"].stringValue
                committee.isCurrent = com["isCurrent"].boolValue
                committee.startDate = com["startDate"].stringValue
                committee.stopDate = com["stopDate"].stringValue

                RealmCoordinator.save(collection: [committee])
                comitteeCoexecutor.append(committee)
            }
        }

        // Stage ==============================================================================
        let lastEventStageId = json["lastEvent"]["stage"]["id"].intValue
        if let stage = RealmCoordinator.loadObject(Stage_.self, byId: lastEventStageId) {
            lastEventStage = stage
        } else {
            let stage = Stage_()
            stage.id = lastEventStageId
            stage.name = json["lastEvent"]["stage"]["name"].stringValue

            RealmCoordinator.save(object: stage)
            lastEventStage = stage
        }

        // Phase ==============================================================================
        let lastEventPhaseId = json["lastEvent"]["phase"]["id"].intValue
        if let phase = RealmCoordinator.loadObject(Phase_.self, byId: lastEventPhaseId) {
            lastEventPhase = phase
        } else {
            let phase = Phase_()
            phase.id = lastEventPhaseId
            phase.name = json["lastEvent"]["phase"]["name"].stringValue

            RealmCoordinator.save(object: phase)
            lastEventPhase = phase
        }

        // Solution ==============================================================================
        lastEventSolutionDescription = json["lastEvent"]["solution"].stringValue
        lastEventDate = json["lastEvent"]["date"].stringValue
        lastEventDocumentName = json["lastEvent"]["document"]["name"].stringValue
        lastEventDocumentType = json["lastEvent"]["document"]["type"].stringValue
    }

    override static func primaryKey() -> String {
        return "number"
    }

    // MARK: - Helper functions

    func generateFullSolutionDescription() -> String {
        var output = lastEventSolutionDescription + "\n"
        output += lastEventDocumentType.characters.count > 0 ? lastEventDocumentType + " " : ""
        output += lastEventDocumentName.characters.count > 0 ? lastEventDocumentName + " " : ""
        output += lastEventDate.isoDateToReadableDate() ?? ""
        return output
    }

    func generateSubjectsDescription() -> String? {
        var output: [String] = []
        factions.forEach({output.append($0.name)})
        deputees.forEach({output.append("\($0.position) \($0.name)")})
        federalSubjects.forEach({output.append($0.name)})
        regionalSubjects.forEach({output.append($0.name)})
        return output.joined(separator: "; ")
    }
}
