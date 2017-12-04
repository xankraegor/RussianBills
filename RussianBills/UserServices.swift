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
        downloadCommittees(forced: forced)
        downloadLawClasses(forced: forced)
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

    static func downloadCommittees(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.committee.updateRequired() else {
                return
            }

            Request.committies(current: nil, completion: { (result: [Committee_]) in
                let realm = try? Realm()
                try? realm?.write {
                    realm?.add(result, update: true)
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            })
        }
    }

    static func downloadLawClasses(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.lawClass.updateRequired() else {
                return
            }

            Request.lawClasses { (result: [LawClass_]) in
                let realm = try? Realm()
                try? realm?.write {
                    for obj in result {
                        realm?.add(obj, update: true)
                    }
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            }
        }
    }

    static func downloadTopics(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.topics.updateRequired() else {
                return
            }

            Request.topics { (result: [Topic_]) in
                let realm = try? Realm()
                try? realm?.write {
                    for obj in result {
                        realm?.add(obj, update: true)
                    }
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            }
        }
    }

    static func downloadDeputies(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.deputy.updateRequired() else {
                return
            }

            Request.deputies { (result: [Deputy_]) in
                let realm = try? Realm()
                try? realm?.write {
                    for obj in result {
                        realm?.add(obj, update: true)
                    }
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            }
        }
    }

    static func downloadFederalSubjects(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.federalSubject.updateRequired() else {
                return
            }

            Request.federalSubjects { (result: [FederalSubject_]) in
                let realm = try? Realm()
                try? realm?.write {
                    for obj in result {
                        realm?.add(obj, update: true)
                    }
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            }
        }
    }

    static func downloadRegionalSubjects(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.regionalSubject.updateRequired() else {
                return
            }

            Request.regionalSubjects { (result: [RegionalSubject_]) in
                let realm = try? Realm()
                try? realm?.write {
                    for obj in result {
                        realm?.add(obj, update: true)
                    }
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            }
        }
    }

    static func downloadInstances(forced: Bool = false, completion: VoidToVoid = nil) {
        Dispatcher.shared.dispatchReferenceDownload {
            guard forced || UserDefaultsCoordinator.instances.updateRequired() else {
                return
            }

            Request.instances { (result: [Instance_]) in
                let realm = try? Realm()
                try? realm?.write {
                    for obj in result {
                        realm?.add(obj, update: true)
                    }
                }
                UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: result)
                if let compl = completion {
                    compl()
                }
            }
        }
    }
    
    // MARK: - Bills

    static func downloadBills(withQuery query: BillSearchQuery, completion: (([Bill_], Int) -> Void)? = nil) {

        Request.billSearch(forQuery: query) { (result: [Bill_], totalCount: Int)  in
            let realm = try? Realm()

            for res in result {
                if let existingBill = realm?.object(ofType: Bill_.self, forPrimaryKey: res.number) {
                    // Copy existing parser content
                    res.parserContent = existingBill.parserContent

                    // Check if a favorite bill has changes
                    if let existingFavoriteBillRecord = realm?.object(ofType: FavoriteBill_.self,
                            forPrimaryKey: res.number),
                       res.generateHashForLastEvent() != existingBill.generateHashForLastEvent() {
                        try? realm?.write {
                            existingFavoriteBillRecord.favoriteHasUnseenChanges = true
                        }
                    }
                }
            }

            try? realm?.write {
                realm?.add(result, update: true)
            }

            if let compl = completion {
                compl(result, totalCount)
            }
        }
    }

    static func updateFavoriteBills(forced: Bool = true, completeWithUpdatedCount: ((Int)->Void)? = nil) {
        guard forced || UserDefaultsCoordinator.favorites.updateRequired() else {
            assertionFailure("∆ UserServices info: updateFavoriteBills call revoked due to non-forced manner or non-due timer")
            return
        }

        guard let favoriteBills = try? Realm().objects(FavoriteBill_.self)
                .filter(FavoritesFilters.notMarkedToBeRemoved.rawValue) else {
            assertionFailure("∆ UserServices can not instantiate Realm while updating favorite bills")
            return
        }

        guard favoriteBills.count > 0 else {
            return
        }

        let queries: [BillSearchQuery] = favoriteBills.map{ BillSearchQuery(withNumber: $0.number) }

        for i in 0..<queries.count {
            Dispatcher.shared.favoritesUpdateDispatchGroup.enter()
            Dispatcher.shared.billsPrefetchDispatchQueue.async() {

                guard let number = queries[i].number,
                    let bill = try? Realm().objects(Bill_.self).filter("number = '\(number)'").first,
                    let existingBill = bill else {
                        assertionFailure("∆ Bill record by number \(queries[i].number ?? "nil") missing in Realm while updating favorite bills")
                        return
                }

                let existingBillParserContent = existingBill.parserContent
                let previousHashValue = existingBill.generateHashForLastEvent()

                Request.billSearch(forQuery: queries[i]) { (result: [Bill_], _) in
                    
                    guard let downloadedBill = result.first else {
                        assertionFailure("∆ Bill not received after querying by number \(queries[i].number ?? "nil") while updating favorite bills")
                        return
                    }

                    try? Realm().write {
                        // Did last event changed since the last update?
                        if downloadedBill.generateHashForLastEvent() != previousHashValue {
                            favoriteBills[i].favoriteHasUnseenChanges = true
                        }
                        downloadedBill.parserContent = existingBillParserContent
                        try? Realm().add(downloadedBill, update: true)
                        Dispatcher.shared.favoritesUpdateDispatchGroup.leave()
                    }

                }
            }
        }

        Dispatcher.shared.favoritesUpdateDispatchGroup.notify(queue: .main) {
            UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: Array(favoriteBills))
            let favoriteBillsWithUnseenChanges = try? Realm().objects(FavoriteBill_.self)
                    .filter(FavoritesFilters.both.rawValue).count
            if let completion = completeWithUpdatedCount {
                completion(favoriteBillsWithUnseenChanges ?? 0)
            }
        }
    }

    // MARK: - Parsed content

    static func setParserContent(ofBillNr billNr: String, to content: BillParserContent?) {
        let realm = try? Realm()
        let newContent = content?.serialize()
        let bill = realm?.object(ofType: Bill_.self, forPrimaryKey: billNr)
        try? realm?.write {
            bill?.parserContent = newContent
        }
    }

    // MARK: - Attachments

    static func pathForDownloadAttachment(forBillNumber: String, withLink link: String)->String? {
        let billAttachmentsDirectory = FilesManager.attachmentDir(forBillNumber: forBillNumber)
        if let docId = FilesManager.extractUniqueDocumentNameFrom(urlString: link),
           let path = FilesManager.pathForFile(containingInName: docId, inDirectory: billAttachmentsDirectory) {
            return path
        } else {
            return nil
        }
    }

    static func downloadAttachment(forBillNumber billNumber: String, withLink downloadLink: String,
                                   updateProgressStatus: @escaping (Double)->Void, completion: VoidToVoid) {
        let fileId = FilesManager.extractUniqueDocumentNameFrom(urlString: downloadLink)
        let billAttachmentsDirectory = FilesManager.attachmentDir(forBillNumber: billNumber)
        let temporaryFileName = String(downloadLink.hashValue)
        let temporaryFullPath = URL(fileURLWithPath: billAttachmentsDirectory).appendingPathComponent(temporaryFileName).path

        FilesManager.createDirectory(atPath: billAttachmentsDirectory)

        let destinationAF: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(fileURLWithPath: temporaryFullPath), [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(downloadLink, to: destinationAF)

            .downloadProgress(closure: { (progress) in
                // For UI update
                DispatchQueue.main.async {
                    updateProgressStatus(progress.fractionCompleted)
                }
            })

            .validate()

            .responseData(queue: Dispatcher.shared.attachmentsDownloadQueue, completionHandler: { (response) in
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
                        FilesManager.renameFile(named: temporaryFileName, atPath: billAttachmentsDirectory, newName: targetFileName)
                        if let comp = completion {
                            comp()
                        }
                    }
                }
            })
    }

    static func deleteAttachment(usingKey key: String, forBillNr: String) {
        let attachmentsDir = FilesManager.attachmentDir(forBillNumber: forBillNr)
        if let filePath = FilesManager.pathForFile(containingInName: key, inDirectory: attachmentsDir) {
            FilesManager.deleteFile(atPath: filePath)
        } else {
            debugPrint("∆ UserServices.deleteAttachment cannot generate filePath to delete the file. The file may be already deleted or moved")
        }
    }

}
