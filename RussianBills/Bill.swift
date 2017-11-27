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


final class Bill_: Object, InitializableWithJson {

    @objc dynamic var number: String = ""
    @objc dynamic var name: String = ""

    @objc dynamic var id: Int = 0
    @objc dynamic var lawType: LawType = LawType.federalLaw
    @objc dynamic var comments: String = ""
    @objc dynamic var introductionDate: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var transcriptUrl: String = ""

    let factions = List<Factions_>()
    let deputees = List<Deputy_>()
    let federalSubjects = List<FederalSubject_>()
    let regionalSubjects = List<RegionalSubject_>()

    @objc dynamic var lastEventStage: Stage_?
    @objc dynamic var lastEventPhase: Phase_?
    @objc dynamic var lastEventSolutionDescription: String = ""
    @objc dynamic var lastEventDate: String = ""
    @objc dynamic var lastEventDocumentName: String = ""
    @objc dynamic var lastEventDocumentType: String = ""

    @objc dynamic var comitteeResponsible: Comittee_?
    let comitteeProfile = List<Comittee_>()
    let comitteeCoexecutor = List<Comittee_>()

    @objc dynamic var parserContent: Data?

    /// Look up for a corresponding favoriteBill record
    var favorite: Bool {
        if try! Realm().object(ofType: FavoriteBill_.self, forPrimaryKey: number) != nil {
            return true
        } else {
            return false
        }
    }

    // MARK: - Initialization

    convenience init(withJson json: JSON) {
        self.init()
        // Basic values
        id = json["id"].intValue
        lawType = LawType(rawValue: json["type"]["id"].intValue)!
        name = json["name"].stringValue
        comments = json["comments"].stringValue
        number = json["number"].stringValue
        introductionDate = json["introductionDate"].stringValue
        url = json["url"].stringValue
        transcriptUrl = json["transcriptUrl"].stringValue
        // Compound values
        decodeFactions(json)
        decodeDeputees(json)
        decodeOtherSubjects(json)
        decodeResponsibleCommittee(json)
        decodeProfileCommittees(json)
        decodeCoexecutors(json)
        decodeStages(json)
        decodePhases(json)
        decodeResolution(json)
    }

    override static func primaryKey() -> String {
        return "number"
    }

    // MARK : - Initialization helper functions

    func decodeFactions(_ json: JSON) {
        let realm = try? Realm()
        let factions = json["subject"]["factions"].arrayValue
        var parsedFactions = Set<Factions_>()

        for fac in factions {
            let facId = fac["id"].intValue
            if let faction = realm?.object(ofType: Factions_.self, forPrimaryKey: facId) {
                self.factions.append(faction)
            } else {
                let faction = Factions_()
                faction.id = facId
                faction.name = fac["name"].stringValue

                parsedFactions.insert(faction)
                self.factions.append(faction)
            }
        }

        try? realm?.write {
            realm?.add(parsedFactions, update: true)
        }

    }

    func decodeDeputees(_ json: JSON) {
        let realm = try? Realm()
        let deputies = json["subject"]["deputies"].arrayValue
        var parsedDeputees = Set<Deputy_>()

        for dep in deputies {
            let depId = dep["id"].intValue
            if let deputy = realm?.object(ofType: Deputy_.self, forPrimaryKey: depId) {
                deputees.append(deputy)
            } else {
                let deputy = Deputy_()
                deputy.id = depId
                deputy.name = dep["name"].stringValue
                deputy.isCurrent = dep["isCurrent"].boolValue
                deputy.position = dep["position"].stringValue

                parsedDeputees.insert(deputy)
                deputees.append(deputy)
            }
        }

        try? realm?.write {
            realm?.add(parsedDeputees, update: true)
        }
    }

    func decodeOtherSubjects(_ json: JSON) {
        let realm = try? Realm()
        let subjects = json["subject"]["departments"].arrayValue
        for sub in subjects {
            let subId = sub["id"].intValue

            if let fedSub = realm?.object(ofType: FederalSubject_.self, forPrimaryKey: subId) {
                try? realm?.write {
                    realm?.add(fedSub, update: true)
                }
                federalSubjects.append(fedSub)
            } else if let regSub = realm?.object(ofType: RegionalSubject_.self, forPrimaryKey: subId) {
                try? realm?.write {
                    realm?.add(regSub, update: true)
                }
                regionalSubjects.append(regSub)
            } else {
                debugPrint("∆ Federal or regional subject could not be found in Realm and parser can't decide, whether the value posted hereafter is federal or reginal subject: \(sub)")
            }
        }
    }

    func decodeResponsibleCommittee(_ json: JSON) {
        let comitteeId = json["committees"]["responsible"]["id"].intValue
        let realm = try? Realm()

        if let committeeById = realm?.object(ofType: Comittee_.self, forPrimaryKey: comitteeId) {
            comitteeResponsible = committeeById
        } else {
            let committee = Comittee_()
            committee.id = comitteeId
            committee.name = json["committees"]["responsible"]["name"].stringValue
            committee.isCurrent = json["committees"]["responsible"]["isCurrent"].boolValue
            committee.startDate = json["committees"]["responsible"]["startDate"].stringValue
            committee.stopDate = json["committees"]["responsible"]["stopDate"].stringValue

            try? realm?.write {
                realm?.add(committee, update: true)
            }

            comitteeResponsible = committee
        }
    }

    func decodeProfileCommittees(_ json: JSON) {
        let realm = try? Realm()
        let profileComs = json["committees"]["profile"].arrayValue
        var parsedCommitees = Set<Comittee_>()

        for com in profileComs {
            let comitteeId = com["id"].intValue
            if let committeeById = realm?.object(ofType: Comittee_.self, forPrimaryKey: comitteeId) {
                comitteeProfile.append(committeeById)
            } else {
                let committee = Comittee_()
                committee.id = comitteeId
                committee.name = com["name"].stringValue
                committee.isCurrent = com["isCurrent"].boolValue
                committee.startDate = com["startDate"].stringValue
                committee.stopDate = com["stopDate"].stringValue

                parsedCommitees.insert(committee)
                comitteeProfile.append(committee)
            }
        }

        try? realm?.write {
            realm?.add(parsedCommitees, update: true)
        }
    }

    func decodeCoexecutors(_ json: JSON) {
        let realm = try? Realm()
        let coexecs = json["committees"]["soexecutor"].arrayValue
        var parsedCommitees = Set<Comittee_>()

        for com in coexecs {
            let comitteeId = com["id"].intValue
            if let committee = realm?.object(ofType: Comittee_.self, forPrimaryKey: comitteeId) {
                comitteeCoexecutor.append(committee)
            } else {
                let committee = Comittee_()
                committee.id = comitteeId
                committee.name = com["name"].stringValue
                committee.isCurrent = com["isCurrent"].boolValue
                committee.startDate = com["startDate"].stringValue
                committee.stopDate = com["stopDate"].stringValue

                parsedCommitees.insert(committee)
                comitteeCoexecutor.append(committee)
            }
        }

        try? realm?.write {
            realm?.add(parsedCommitees, update: true)
        }
    }

    func decodeStages(_ json: JSON) {
        let realm = try? Realm()
        let lastEventStageId = json["lastEvent"]["stage"]["id"].intValue
        if let stage = realm?.object(ofType: Stage_.self, forPrimaryKey: lastEventStageId) {
            lastEventStage = stage
        } else {
            let stage = Stage_()
            stage.id = lastEventStageId
            stage.name = json["lastEvent"]["stage"]["name"].stringValue
            try? realm?.write {
                realm?.add(stage, update: true)
            }
            lastEventStage = stage
        }
    }

    func decodePhases(_ json: JSON) {
        let realm = try? Realm()
        let lastEventPhaseId = json["lastEvent"]["phase"]["id"].intValue
        if let phase = realm?.object(ofType: Phase_.self, forPrimaryKey: lastEventPhaseId) {
            lastEventPhase = phase
        } else {
            let phase = Phase_()
            phase.id = lastEventPhaseId
            phase.name = json["lastEvent"]["phase"]["name"].stringValue

            try? realm?.write {
                realm?.add(phase, update: true)
            }
            lastEventPhase = phase
        }
    }

    func decodeResolution(_ json: JSON) {
        lastEventSolutionDescription = json["lastEvent"]["solution"].stringValue
        lastEventDate = json["lastEvent"]["date"].stringValue
        lastEventDocumentName = json["lastEvent"]["document"]["name"].stringValue
        lastEventDocumentType = json["lastEvent"]["document"]["type"].stringValue
    }

    // MARK: - Helper functions

    func generateFullSolutionDescription() -> String {
        var output = lastEventSolutionDescription + "\n"
        output += lastEventDocumentType.count > 0 ? lastEventDocumentType + " " : ""
        output += lastEventDocumentName.count > 0 ? lastEventDocumentName + " " : ""
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

    func generateCoexecitorCommitteesDescription() -> String? {
         return comitteeCoexecutor.map{$0.name}.joined(separator: "; ")
    }

    func generateProfileCommitteesDescription()->String? {
        return comitteeProfile.map{$0.name}.joined(separator: "; ")
    }

    private func replace(WithText replacementText: String, ifMissingSourceText source: String)->String {
        let textWithoutSpaces = source.trimmingCharacters(in: .whitespacesAndNewlines)
        return textWithoutSpaces.count > 0 ? source : replacementText
    }

    public func generateHashForLastEvent()->String {
        let lastEventStageDescr = lastEventStage?.name ?? ""
        let lastEventStageHash = lastEventStageDescr.hashValue
        let lastEventPhaseDescr = lastEventPhase?.name ?? ""
        let lastEventPhaseHash = lastEventPhaseDescr.hashValue
        let lastEventSolutionDescriptionHash = lastEventSolutionDescription.hashValue
        let lastEventDateHash = lastEventDate.hashValue
        print("∆∆ Bill \(number) last event date: \(lastEventDate) hash \(lastEventDateHash)")
        let lastEventDocumentNameHash = lastEventDocumentName.hashValue
        let lastEventDocumentTypeHash = lastEventDocumentType.hashValue
        let combinedHash = "\(lastEventStageHash)\(lastEventPhaseHash)\(lastEventSolutionDescriptionHash)\(lastEventDateHash)\(lastEventDocumentNameHash)\(lastEventDocumentTypeHash)"
        return combinedHash
    }

    // MARK: - Additional Description

    override var description: String {
        let repl = "отсутствует"
        var output = ""

        output += "Проект нормативно-правового акта №" + replace(WithText: repl, ifMissingSourceText: number) + "\n"
        output += "Тип нормативно-правового акта: " + replace(WithText: repl, ifMissingSourceText: lawType.description) + "\n"
        output += "Наименование проекта нормативно-правового акта: " + replace(WithText: repl, ifMissingSourceText: name) + "\n"
        output += "Описание проекта нормативно-правового акта: " + replace(WithText: repl, ifMissingSourceText: comments) + "\n"
        output += "Внёсен: " + replace(WithText: repl, ifMissingSourceText: introductionDate) + "\n"
        output += "Субъекты законодательной инициативы: " + replace(WithText: repl, ifMissingSourceText: generateSubjectsDescription() ?? "") + "\n"

        if let content = parserContent, let parser = BillParserContent.deserialize(data: content) {
            output += "СОБЫТИЯ РАССМОТРЕНИЯ ПРОЕКТА НОРМАТИВНО-ПРАВОВОГО АКТА\n"
            for phase in parser.phases {
                output += String(repeating: " ", count: 5)
                for event in phase.events {
                    output += "\n"
                    output += String(repeating: " ", count: 10) + replace(WithText: "Название события не указано", ifMissingSourceText: event.name ) + "\n"
                    output += String(repeating: " ", count: 10) + replace(WithText: "Дата события не указана", ifMissingSourceText: event.date ?? "") + "\n"
                    output += String(repeating: " ", count: 10) + "Прикреплено документов: " + String(event.attachments.count) + "\n"
                }
            }
        } else {
            output += "Текущая стадия рассмотрения: " + replace(WithText: repl, ifMissingSourceText: lastEventStage?.name ?? "") + "\n"
            output += "Текущая фаза рассмотрения: " + replace(WithText: repl, ifMissingSourceText: lastEventPhase?.name ?? "") + "\n"
            output += "Принятое решение: " + replace(WithText: repl, ifMissingSourceText: generateFullSolutionDescription()) + "\n"
        }

        return output
    }

}
