//
//  RequestRouter.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Alamofire

enum RequestRouter: URLRequestConvertible {

    // API Functions
    case search(bill: BillSearchQuery)
    case committees(current: Bool?)
    case topics
    case classes
    case deputy(beginsWithChars: String?, position: DeputyPosition?, current: Bool?)
    case federalSubject(current: Bool?)
    case regionalSubject(current: Bool?)
    case instances(current: Bool?)

    // Parsing
    case bill(number: String)
    case document(link: String)

    private var method: HTTPMethod {
        return .get
    }

    private func baseUrl() throws -> URL? {
        switch self {
        case .bill(number: _):
            return nil
        case .document(link: _):
            return try "http://asozd2.duma.gov.ru".asURL()
        default:

            return (try "http://api.duma.gov.ru/api/".asURL()).appendingPathComponent(apiKey)
        }
    }

    private var path: String {
        switch self {
        case .committees(current: _):
            return "/committees.json"
        case .search(bill: _):
            return "/search.json"
        case .topics:
            return "/topics.json"
        case .classes:
            return "/classes.json"
        case .deputy(beginsWithChars: _, position: _, current: _):
            return "/deputies.json"
        case .federalSubject(current: _):
            return "/federal-organs.json"
        case .regionalSubject(current: _):
            return "/regional-organs.json"
        case .instances(current: _):
            return "/instances.json"
        case .bill(number: _):
            return ""
        case let .document(link):
            return link
        }
    }

    private var parameters: Parameters {
        var dict = ["app_token": appToken]
        switch self {

                // Early exit cases

        case let .bill(number):
            return ["OpenAgent": "", "RN": number]
        case .document(link: _):
            return [:]

                // Full cycle cases

        case let .search(bill):
            var billParameters = RequestRouter.generateBillRequestParameters(forQuery: bill)
            billParameters["app_token"] = appToken
            return billParameters

        case let .deputy(beginsWithChars, position, current):
            if let initialChars = beginsWithChars {
                dict["begin"] = initialChars
            }
            if let deputyPosition = position {
                dict["position"] = deputyPosition.rawValue
            }
            if let isDeputyCurrent = current {
                dict["current"] = isDeputyCurrent ? "1" : "0"
            }
        case let .federalSubject(current),
             let .regionalSubject(current),
             let .committees(current),
             let .instances(current):
            if let currentState = current {
                dict["current"] = currentState ? "1" : "0"
            }
        case .topics, .classes:
            break
        }

        return dict
    }

    /// Returns a URL request or throws if an `Error` was encountered.
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    /// - returns: A URL request.
    func asURLRequest() throws -> URLRequest {
        // Base URL + API code for non-parsed categories
        let url = try baseUrl()
        // Path URL + App Key for non-parsed categories
        var urlRequest = URLRequest(url: url!.appendingPathComponent(path))
        urlRequest.allowsCellularAccess = true
        // Generating request
        switch self {
        case .document(_):
            break
        default:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            break
        }
        return urlRequest
    }

    func documentStringLink() -> String? {
        switch self {
        case let .document(link):
            // OLD: http://asozd2.duma.gov.ru/main.nsf/(ViewDoc)?OpenAgent&work/dz.nsf/ByID&FA2D700A-5146-49F1-A20B-A96D57480918
            // NEW: http://sozd.parlament.gov.ru/download/FA2D700A-5146-49F1-A20B-A96D57480918
            return "http://sozd.parlament.gov.ru/download/\(FilesManager.extractUniqueDocumentNameFrom(urlString: link)!)"//.replacingOccurrences(of: "%3F", with: "?")
        default:
            return nil
        }
    }

    // MARK: - Keys ref

    var apiKey: String {
        if UserDefaultsCoordinator.getUsingCustomKeys() {
            return UserDefaultsCoordinator.customApiKeys()?.apiKey ?? ""
        } else {
            return UserDefaultsCoordinator.apiKey()
        }
    }

    var appToken: String {
        if UserDefaultsCoordinator.getUsingCustomKeys() {
            return UserDefaultsCoordinator.customApiKeys()?.appToken ?? ""
        } else {
            return UserDefaultsCoordinator.appToken()
        }
    }


}
