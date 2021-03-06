//
//  RequestFunctionsProvider.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import Kanna

/* ================================================================================
 
 Having added new methods to this enum, keep it in consistency with UserServices
 
 ================================================================================= */

enum Request {

    // MARK: - Bill Search Request Function

    // NOT Enqueued
    static func billSearch(forQuery bill: BillSearchQuery, completion: @escaping ([Bill_], Int, NSError?) -> Void) {
        if let requestMessage = RequestRouter.search(bill: bill).urlRequest {

            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let error1 = response.error {
                    debugPrint("∆ Request.billSearch returned an error: \(error1.localizedDescription)")
                    let error = NSError(.mainAppl, code: .billSearchResponseErrorCode, message: error1.localizedDescription)
                    completion([], 0, error)
                    return
                }

                if let error2 = response.result.error {
                    debugPrint("∆ Request.billSearch result returned an error: \(error2.localizedDescription)")
                    let error = NSError(.mainAppl, code: .billSearchResponseErrorCode, message: error2.localizedDescription)
                    completion([], 0, error)
                    return
                }

                if let contents = response.result.value {
                    let json = JSON(contents)

                    guard json["code"].intValue == 0 else {
                        if let errorText = json["text"].string {
                            let error = NSError(.mainAppl, code: .billSearchResponseErrorCode, message: "code \(json["code"].intValue): \(errorText)")
                            completion([], 0, error)
                            return
                        } else {
                            let error = NSError(.mainAppl, code: .billSearchResponseErrorCode, message: "code \(json["code"].intValue): error text missing, using the whole Json answer instead: \(String(describing: response.result.value))")
                            completion([], 0, error)
                        }
                        return
                    }

                    let totalCount: Int = json["count"].intValue
                    var bills: [Bill_] = []
                    for law in json["laws"] {
                        let billToStore = Bill_(withJson: law.1)
                        bills.append(billToStore)
                    }
                    completion(bills, totalCount, nil)
                }
            }
        } else {
            assertionFailure("Cannot generate a bill request")
        }
    }

    // Enqueued
    static func htmlToParse(forUrl url: URL, completion: @escaping (HTMLDocument?, NSError?) -> Void) {
        Alamofire.request(url).responseData(queue: Dispatcher.shared.htmlParseQueue) { (response) in
            if let error1 = response.error {
                debugPrint("∆ Request.billSearch returned an error: \(error1.localizedDescription)")
                let error = NSError(.mainAppl, code: .billSearchResponseErrorCode, message: error1.localizedDescription)
                completion(nil, error)
                return
            }

            if let error2 = response.result.error {
                debugPrint("∆ Request.billSearch result returned an error: \(error2.localizedDescription)")
                let error = NSError(.mainAppl, code: .billSearchResponseErrorCode, message: error2.localizedDescription)
                completion(nil, error)
                return
            }

            let err: NSError?
            if let resp = response.response,
               resp.statusCode / 100 != 2 { // Non-normal response
                err = NSError(.mainAppl, code: .parsingResponseErrorCode, message: "HTML respnose code \(resp.statusCode)")
                debugPrint("∆ Parser [\(Date())] received HTTPURLResponse with status code: \(resp.statusCode)")
            } else {
                err = nil
            }

            if let doc = try? HTML(url: url, encoding: String.Encoding.utf8) {
                completion(doc, err)
            }
        }
    }

    // MARK: - Other request Functions

    static func committies(current: Bool? = nil, completion: @escaping ([Committee_]) -> Void) {
        if let requestMessage = RequestRouter.committees(current: current).urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var committies: [Committee_] = []
                    for item in json {
                        let comittee = Committee_(withJson: item.1)
                        committies.append(comittee)
                    }
                    completion(committies)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about committees")
        }
    }

    static func lawClasses(completion: @escaping ([LawClass_]) -> Void) {
        if let requestMessage = RequestRouter.classes.urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var lawClasses: [LawClass_] = []
                    for item in json {
                        let lawClass = LawClass_(withJson: item.1)
                        lawClasses.append(lawClass)
                    }
                    completion(lawClasses)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about law classes")
        }
    }

    static func topics(completion: @escaping ([Topic_]) -> Void) {
        if let requestMessage = RequestRouter.topics.urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var topics: [Topic_] = []
                    for item in json {
                        let topic = Topic_(withJson: item.1)
                        topics.append(topic)
                    }
                    completion(topics)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about topics")
        }
    }

    static func deputies(beginsWithChars: String? = nil, position: DeputyPosition? = nil, current: Bool? = nil, completion: @escaping ([Deputy_]) -> Void) {
        if let requestMessage = RequestRouter.deputy(beginsWithChars: beginsWithChars, position: position, current: current).urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var deputies: [Deputy_] = []
                    for item in json {
                        let deputy = Deputy_(withJson: item.1)
                        deputies.append(deputy)
                    }
                    completion(deputies)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about deputies")
        }
    }

    static func federalSubjects(current: Bool? = nil, completion: @escaping ([FederalSubject_]) -> Void) {
        if let requestMessage = RequestRouter.federalSubject(current: current).urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var subjects: [FederalSubject_] = []
                    for item in json {
                        let subject = FederalSubject_(withJson: item.1)
                        subjects.append(subject)

                    }
                    completion(subjects)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about federal subjects")
        }
    }

    static func regionalSubjects(current: Bool? = nil, completion: @escaping ([RegionalSubject_]) -> Void) {
        if let requestMessage = RequestRouter.regionalSubject(current: current).urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var subjects: [RegionalSubject_] = []
                    for item in json {
                        let subject = RegionalSubject_(withJson: item.1)
                        subjects.append(subject)
                    }
                    completion(subjects)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about regional subjects")
        }
    }

    static func instances(current: Bool? = nil, completion: @escaping ([Instance_]) -> Void) {
        if let requestMessage = RequestRouter.instances(current: current).urlRequest {
            Alamofire.request(requestMessage).responseJSON(queue: Dispatcher.shared.referenceDownloadDispatchQueue) { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var instances: [Instance_] = []
                    for item in json {
                        let instance = Instance_(withJson: item.1)
                        instances.append(instance)
                    }
                    completion(instances)
                }
            }
        } else {
            assertionFailure("Cannot generate a request about instances")
        }
    }

}
