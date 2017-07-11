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

enum UserServices {
    typealias VoidToVoid = ((Void)->Void)?

    // MARK:- Download support categories

    static func downloadAllSupportCategories(completion: VoidToVoid = nil) {
        downloadComittees()
        downloadLawCalsses()
        downloadTopics()
        downloadDeputies()
        downloadFederalSubjects()
        downloadRegionalSubjects()
        downloadInstances()
        
        // TODO: Completion after functions finshed their completion
        if let compl = completion {
            compl()
        }
    }

    static func downloadComittees(completion: VoidToVoid = nil) {
        Request.comittees(current: true, completion: { (result: [Comittee_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        })
    }

    static func downloadLawCalsses(completion: VoidToVoid = nil) {
        Request.lawClasses() { (result: [LawClass_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadTopics(completion: VoidToVoid = nil) {
        Request.topics() { (result: [Topic_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadDeputies(completion: VoidToVoid = nil) {
        Request.deputies() { (result: [Deputy_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadFederalSubjects(completion: VoidToVoid = nil) {
        Request.federalSubjects() { (result: [FederalSubject_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }

    }

    static func downloadRegionalSubjects(completion: VoidToVoid = nil) {
        Request.regionalSubjects() { (result: [RegionalSubject_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }
    
    static func downloadInstances(completion: VoidToVoid = nil) {
        Request.instances() { (result: [Instance_]) in
            RealmCoordinator.save(collection: result)
            if let compl = completion {
                compl()
            }
        }
    }
    

    // MARK:- Bills

    // По умолчанию загружается не более 20 штук за раз!
    // TODO: Сделать выгрузку большего количества или автоматическую подгрузку
    static func downloadBills(withQuery query: BillSearchQuery, completion: VoidToVoid = nil) {
            Request.billSearch(forQuery: query, completion: { (result: [Bill_]) in
            RealmCoordinator.save(collection: result)
                if let compl = completion {
                    compl()
                }
        })
    }



}
