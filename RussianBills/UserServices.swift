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
            guard forced || UserDefaultsCoordinator.committee.updateRequired() else {
                return
            }

            Request.comittees(current: nil, completion: { (result: [Comittee_]) in
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

    static func downloadLawCalsses(forced: Bool = false, completion: VoidToVoid = nil) {
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

    static func downloadBills(withQuery query: BillSearchQuery, completion: (([Bill_]) -> Void)? = nil) {
        Request.billSearch(forQuery: query, completion: { (result: [Bill_]) in
            let realm = try? Realm()
            for res in result {
                if let existingBill = realm?.object(ofType: Bill_.self, forPrimaryKey: res.number) {
                    res.favorite = existingBill.favorite
                    if (res.favorite && existingBill.generateHashForLastEvent() != res.generateHashForLastEvent()) || existingBill.favoriteHasUnseenChanges == true {
                        res.favoriteHasUnseenChanges = true
                    }
                    res.favoriteUpdatedTimestamp = existingBill.favoriteUpdatedTimestamp
                    res.parserContent = existingBill.parserContent
                }
            }

            try? realm?.write {
                realm?.add(result, update: true)
            }

            if let compl = completion {
                compl(result)
            }
        })
    }

    static func updateFavoriteBills(forced: Bool, completionWithUpdatedCount: ((Int)->Void)? = nil) {
        guard forced || UserDefaultsCoordinator.favorites.updateRequired() else {
            debugPrint("∆ UserServices info: updateFavoriteBills call revoked due to non-forced manner or ")
            return
        }

        guard let favoriteBills = try? Realm().objects(Bill_.self).filter("favorite == true"), favoriteBills.count > 0 else {
            debugPrint("∆ UserServices can't instantiate Realm while updating favorite bills or favorite bills count equals zero")
            return
        }

        var updatedCount = 0

        let queries: [BillSearchQuery] = favoriteBills.map{ BillSearchQuery(withNumber: $0.number) }

        for query in queries {
            Dispatcher.shared.favoritesUpdateDispatchGroup.enter()
            Dispatcher.shared.billsPrefetchDispatchQueue.async() {

                guard let existingBill = try! Realm().objects(Bill_.self).filter("number = '\(query.number!)'").first else {
                    debugPrint("∆ Bill record \(query.number!) missing in Realm while updating favorite bills")
                    return
                }

                let existingBillParserContent = existingBill.parserContent
                let existingBillFavoriteUpdatedTimestamp = existingBill.favoriteUpdatedTimestamp
                let existingBillFavoriteHasUnseenChanges = existingBill.favoriteHasUnseenChanges

                let previousHashValue = existingBill.generateHashForLastEvent()
                debugPrint("Previous hash value for \(existingBill.number) is: \(existingBill.generateHashForLastEvent())" )

                Request.billSearch(forQuery: query, completion: { (result: [Bill_]) in

                    guard let downloadedBill = result.first else {
                        debugPrint("∆ No bills recieved when querying \(query.number!) while updating favorite bills")
                        return
                    }

                    // Did last event changed since the last update?
                    debugPrint("New hash value for \(downloadedBill.number) is: \(downloadedBill.generateHashForLastEvent())" )
                    if (downloadedBill.generateHashForLastEvent() != previousHashValue) || (existingBillFavoriteHasUnseenChanges) {
                        debugPrint("\(downloadedBill.number) has updates")
                        downloadedBill.favoriteHasUnseenChanges = true
                        updatedCount += 1
                    }

                    downloadedBill.favorite = true
                    downloadedBill.parserContent = existingBillParserContent
                    downloadedBill.favoriteUpdatedTimestamp = existingBillFavoriteUpdatedTimestamp

                    try? Realm().write {
                        try? Realm().add(downloadedBill, update: true)
                    }

                    Dispatcher.shared.favoritesUpdateDispatchGroup.leave()
                })
            }

        }

        Dispatcher.shared.favoritesUpdateDispatchGroup.notify(queue: .main) {
            debugPrint("∆ updateFavoriteBills completion handler")
            UserDefaultsCoordinator.updateTimestampUsingClassType(ofCollection: Array(favoriteBills))
            if let completion = completionWithUpdatedCount {
                completion(updatedCount)
            }
        }
    }


    static func downloadNonExistingBillBySync(withNumber number: String, favoriteTimestamp: Double) {
        let query = BillSearchQuery(withNumber: number)
        Request.billSearch(forQuery: query, completion: { (result: [Bill_]) in
            if let bill = result.first {
                let realm = try? Realm()
                bill.favorite = true
                bill.favoriteUpdatedTimestamp = favoriteTimestamp
                try? realm?.write {
                    realm?.add(bill, update: true)
                }
            }
        })
    }

    // MARK: - Parsed content

    static func setParserContent(ofBillNr billNr: String, to content: BillParserContent?) {
        let realm = try? Realm()
        let newContent = content?.serialize()
        let bill = realm?.object(ofType: Bill_.self, forPrimaryKey: billNr)
        try? realm?.write {
            bill!.parserContent = newContent
        }
    }

    // MARK: - Attachments

    static func pathForDownloadAttachment(forBillNumber: String, withLink link: String)->String? {
        let billAttacmentsDirectory = FilesManager.attachmentDir(forBillNumber: forBillNumber)
        if let docId = FilesManager.extractUniqueDocumentNameFrom(urlString: link), let path = FilesManager.pathForFile(containingInName: docId, inDirectory: billAttacmentsDirectory) {
            return path
        } else {
            return nil
        }
    }

    static func downloadAttachment(forBillNumber billNumber: String, withLink downladLink: String, updateProgressStatus: @escaping (Double)->Void, completion: VoidToVoid) {
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
                        FilesManager.renameFile(named: temporaryFileName, atPath: billAttacmentsDirectory, newName: targetFileName)
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
