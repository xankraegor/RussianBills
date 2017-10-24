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

        Dispatcher.shared.referenceDownloadDispatchGroup.notify(queue: DispatchQueue.main) {
            if let compl = completion {
                compl()
            }
        }
    }

    static func downloadComittees(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.committee.referenceValuesUpdateRequired() else {
                return
            }

            Request.comittees(current: nil, completion: { (result: [Comittee_]) in
                RealmCoordinator.save(collection: result)
                if let compl = completion {
                    compl()
                }
            })
        }
    }

    static func downloadLawCalsses(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
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
    }

    static func downloadTopics(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
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
    }

    static func downloadDeputies(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
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
    }

    static func downloadFederalSubjects(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
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
    }

    static func downloadRegionalSubjects(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
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
    }

    static func downloadInstances(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
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
    }
    
    // MARK: - Bills

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


    // MARK: - Attachments

    static func isAttachmentDownloaded(forBillNumber: String, withLink link: String)->Bool {
        let billAttacmentsDirectory = FilesManager.attachmentDir(forBillNumber: forBillNumber)
        if let docId = FilesManager.extractUniqueDocumentNameFrom(urlString: link), let _ = FilesManager.pathForFile(containingInName: docId, inDirectory: billAttacmentsDirectory) {
            return true
        } else {
            return false
        }
    }

    static func downloadAttachment(forBillNumber billNumber: String, withLink downladLink: String, updateProgressStatus: @escaping (Double)->Void, fileURL: @escaping (String)->Void ) {
        let fileId = FilesManager.extractUniqueDocumentNameFrom(urlString: downladLink)
        let billAttacmentsDirectory = FilesManager.attachmentDir(forBillNumber: billNumber)
        let temporaryFileName = String(downladLink.hashValue)
        let temporaryFullPath = URL(fileURLWithPath: billAttacmentsDirectory).appendingPathComponent(temporaryFileName).path

        FilesManager.createDirectory(atPath: billAttacmentsDirectory)

        let destinationAF: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(fileURLWithPath: temporaryFullPath), [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(downladLink, to: destinationAF)

            .downloadProgress(closure: { (progress) in
                print("\(progress.fractionCompleted * 100)% downloaded")
                // For UI update
                DispatchQueue.main.async {
                    updateProgressStatus(progress.fractionCompleted)
                }
            })

            .validate()

            .responseData(completionHandler: { (response) in
                if let error = response.result.error as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")

                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                } else {
                    if let suggestedFullFileName = response.response?.suggestedFilename?.removingPercentEncoding,
                        let fileId = fileId {
                        let suggestedExtension = URL(fileURLWithPath: suggestedFullFileName).pathExtension
                        let fileNameWithoutExtension = URL(fileURLWithPath: suggestedFullFileName).deletingPathExtension()
                        let targetFileName = "\(fileNameWithoutExtension.lastPathComponent.removingPercentEncoding ?? "")_#\(fileId).\(suggestedExtension)"
                        FilesManager.renameFile(named: temporaryFileName, atPath: billAttacmentsDirectory, newName: targetFileName)
                    }
                }
            })
    }

}
