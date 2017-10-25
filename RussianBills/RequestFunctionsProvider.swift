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

    static func billSearch(forQuery bill: BillSearchQuery, completion: @escaping ([Bill_])->Void ) {
        if let reqestMessage = RequestRouter.search(bill: bill).urlRequest {
            Alamofire.request(reqestMessage).responseJSON { response in
                if let contents = response.result.value {
                    let json = JSON(contents)
                    var bills: [Bill_] = []
                    for law in json["laws"] {
                        let billToStore = Bill_(withJson: law.1, favoriteMark: false)
                        bills.append(billToStore)
                    }
                    completion(bills)
                }
            }
        } else {
            debugPrint("Cannot forge a request about regional subjects")
        }
    }

    static func htmlToParse(forUrl url: URL, completion: @escaping (HTMLDocument) -> Void ) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                debugPrint(error!.localizedDescription)
            }

            if let resp = response as? HTTPURLResponse {
                debugPrint("∆ Parser [\(Date())] recieved HTTPURLResponse with status code: \(resp.statusCode)")
            }
            
            Dispatcher.shared.htmlParseQueue.async {
                if let doc = try? HTML(url: url, encoding: String.Encoding.utf8) {
                    completion(doc)
                }
            }
        }).resume()
    }
    
    // MARK: - Attached Document Request Function
    
    static func document(downladLink: String, toSaveAt path: String, progressStatus: @escaping (Double)->Void, completion: @escaping (DownloadResponse<Data>)->Void) {
        
        debugPrint("∆ Request.Document() :: destination: \(path)")
        let destinationAF: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(fileURLWithPath: path), [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(downladLink, to: destinationAF)
            .downloadProgress(closure: { (progress) in
                print("\(progress.fractionCompleted * 100)% downloaded")
                progressStatus(progress.fractionCompleted)
            })
            .validate()
            .responseData(completionHandler: { (response) in

                let suggestedFileName = response.response?.suggestedFilename?.removingPercentEncoding
                print("∆ Response suggestedFileName: \(suggestedFileName ?? "missing")")

                // DEBUG: Somewhere here the Attachments folder is being replaced with an empty file
                if response.error != nil {
                    debugPrint("∆ Can't download \(response.request.debugDescription) due to error: \(response.error.debugDescription)")
                    print(response.description)


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
                    }
                } else {
                    completion(response)
                }
                
            })
    }


    // MARK: - Other request Functions

    static func comittees(current: Bool? = nil, completion: @escaping ([Comittee_])->Void ) {
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

    static func lawClasses(completion: @escaping ([LawClass_])->Void) {
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

    static func topics(completion: @escaping ([Topic_])->Void) {
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

    static func deputies(beginsWithChars: String? = nil, position: DeputyPosition? = nil, current: Bool? = nil, completion: @escaping ([Deputy_])->Void ) {
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

    static func federalSubjects(current: Bool? = nil, completion: @escaping ([FederalSubject_])->Void ) {
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

    static func regionalSubjects(current: Bool? = nil, completion: @escaping ([RegionalSubject_])->Void ) {
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

    static func instances(current: Bool? = nil, completion: @escaping ([Instance_])->Void ) {
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
