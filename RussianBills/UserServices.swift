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
    static func downloadBills(withQuery query: BillSearchQuery, favoriteSelector: UserServicesDownloadBillsFavoriteStatusSelector, completion: (([Bill_]) -> Void)? = nil) {
        
        Request.billSearch(forQuery: query, completion: { (result: [Bill_]) in
            switch favoriteSelector {
            case .none:
                break
            case .makeAllFavorite:
                for res in result {
                    res.favorite = true
                }
            case .preserveFavorite:
                for res in result {
                    res.favorite = RealmCoordinator.getFavoriteStatusOf(billNr: res.number) ?? false
                }
            }
            
            RealmCoordinator.save(collection: result)
            
            if let compl = completion {
                compl(result)
            }
            
        })
    }
    
    // MARK: - Documents

    static func downloadDocument(usingRelativeLink link: String, toDestination dest: String, updateProgressStatus: @escaping (Double)->Void, fileURL: @escaping (String)->Void ) {
        Request.document(documentLink: link, destination: dest, progressStatus: { (progress) in
            // For UI update
            DispatchQueue.main.sync {
                updateProgressStatus(progress)
            }
        }) { (response) in
            
            if let data = response.value, let utf8Text = String(data: data, encoding: .utf8) {
                let fileName = response.destinationURL!.lastPathComponent
                print("Recommended file name: \(fileName)")
                if let uniqueName = FilesManager.extractUniqueDocumentNameFrom(urlString: String(describing: response.request?.url)) {
                    if let suggestedFileName = response.response?.suggestedFilename {
                        let recommendedExtension = suggestedFileName.fileExtension()
                        FilesManager.createAndOrWriteToFile(text: utf8Text, name: "\(uniqueName).\(recommendedExtension)", path: dest)
                        fileURL("\(dest)\(uniqueName).\(recommendedExtension)")
                    }
                }
            }
        }
    }
    
}
