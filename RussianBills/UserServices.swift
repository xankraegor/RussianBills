//
//  UserServices.swift
//  RussianBills
//
//  Created by Xan Kraegor on 08.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

/* ================================================================================
 
 Having added new methods to this enum, keep it in consistency with RequestFunctionsProvider
 
 ================================================================================= */

enum UserServices {
    typealias VoidToVoid = (() -> Void)?

    // MARK: - Download Reference Categories

    static func downloadAllReferenceCategories(forced: Bool = false, completion: VoidToVoid = nil) {
        downloadComittees(forced: forced)
        downloadLawCalsses(forced: forced)
        downloadTopics(forced: forced)
        downloadDeputies(forced: forced)
        downloadFederalSubjects(forced: forced)
        downloadRegionalSubjects(forced: forced)
        downloadInstances(forced: forced)

        // TODO:- Completion after functions finshed their completion
        if let compl = completion {
            compl()
        }
    }

    static func downloadComittees(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.committee.referenceValuesUpdateRequired() else {
            return
        }

        Request.comittees(current: true, completion: { (result: [Comittee_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        })
    }

    static func downloadLawCalsses(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.lawClass.referenceValuesUpdateRequired() else {
            return
        }

        Request.lawClasses { (result: [LawClass_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadTopics(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.topics.referenceValuesUpdateRequired() else {
            return
        }

        Request.topics { (result: [Topic_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadDeputies(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.deputy.referenceValuesUpdateRequired() else {
            return
        }

        Request.deputies { (result: [Deputy_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadFederalSubjects(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.federalSubject.referenceValuesUpdateRequired() else {
            return
        }

        Request.federalSubjects { (result: [FederalSubject_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }

    }

    static func downloadRegionalSubjects(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.regionalSubject.referenceValuesUpdateRequired() else {
            return
        }

        Request.regionalSubjects { (result: [RegionalSubject_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadInstances(forced: Bool = false, completion: VoidToVoid = nil) {
        guard forced || UserDefaultsCoordinator.instances.referenceValuesUpdateRequired() else {
            return
        }

        Request.instances { (result: [Instance_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    // MARK: - Bills

    // По умолчанию загружается не более 20 штук за раз!
    // TODO:- Сделать выгрузку большего количества или автоматическую подгрузку
    static func downloadBills(withQuery query: BillSearchQuery, completion: (([Bill_]) -> Void)? = nil) {
            Request.billSearch(forQuery: query, completion: { (result: [Bill_]) in
            RealmCoordinator.save(collection: result)
                if let compl = completion {
                    compl(result)
                }
        })
    }

}
