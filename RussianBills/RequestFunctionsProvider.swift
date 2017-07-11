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


/* ================================================================================
 
 Having added new methods to this class, keep it in consistency with UserServices
 
================================================================================= */

enum Request {

    // MARK: - Bill Search Request Function

    static func billSearch(forQuery bill: BillSearchQuery, completion: @escaping ([Bill_])->() ) {
        if let reqestMessage = RequestRouter.search(bill: bill).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var bills: [Bill_] = []
                    for law in json["laws"] {
                        let billToStore = Bill_(withJson: law.1)
                        bills.append(billToStore)
                    }
                    completion(bills)
                }
            }
        } else {
            debugPrint("Cannot forge a request about regional subjects")
        }
    }

    // MARK: - Base request function

//    private func requestBody<T>(response: DataResponse<Any>, fetchType: T.Type,
//                             completion: @escaping ([T])->()) where T: Object, T: InitializableWithJson {
//        if let contents = response.result.value {
//            let json = JSON(contents)
//            var colection: [T] = []
//            for itemRaw in json  {
//                let item = T.init(withJson: itemRaw.1)
//                colection.append(item)
//            }
//            completion(colection)
//        }
//    }


    // MARK: - Other request Functions

    static func comittees(current: Bool? = nil, completion: @escaping ([Comittee_])->() ) {
        if let reqestMessage = RequestRouter.committees(current: current).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var comittees: [Comittee_] = []
                    for item in json {
                        let comittee = Comittee_(withJson: item.1)
                        comittees.append(comittee)
                    }
                    completion(comittees)
                }
            }
        } else {
            debugPrint("Cannot forge a request about committees")
        }
    }

    static func lawClasses(completion: @escaping ([LawClass_])->()) {
        if let reqestMessage = RequestRouter.classes.urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
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
            debugPrint("Cannot forge a request about law classes")
        }
    }

    static func topics(completion: @escaping ([Topic_])->()) {
        if let reqestMessage = RequestRouter.topics.urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
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
            debugPrint("Cannot forge a request about topics")
        }
    }

    static func deputies(beginsWithChars: String? = nil, position: DeputyPosition? = nil, current: Bool? = nil, completion: @escaping ([Deputy_])->() ) {
        if let reqestMessage = RequestRouter.deputy(beginsWithChars: beginsWithChars, position: position, current: current).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
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
            debugPrint("Cannot forge a request about deputies")
        }
    }

    static func federalSubjects(current: Bool? = nil, completion: @escaping ([FederalSubject_])->() ) {
        if let reqestMessage = RequestRouter.federalSubject(current: current).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
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
            debugPrint("Cannot forge a request about federal subjects")
        }
    }

    static func regionalSubjects(current: Bool? = nil, completion: @escaping ([RegionalSubject_])->() ) {
        if let reqestMessage = RequestRouter.regionalSubject(current: current).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
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
            debugPrint("Cannot forge a request about regional subjects")
        }
    }


    static func instances(current: Bool? = nil, completion: @escaping ([Instance_])->() ) {
        if let reqestMessage = RequestRouter.instances(current: current).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
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
            debugPrint("Cannot forge a request about instances")
        }
    }



    
}
