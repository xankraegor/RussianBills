//
//  RequestRouter.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Alamofire

// Based on http://api.duma.gov.ru/

enum RequestRouter: URLRequestConvertible {

    private static let baseUrl: String = "http://api.duma.gov.ru/api/"

    case search(bill: BillSearchQuery)
    case committees(current: Bool?)
    case topics
    case classes
    case deputy(beginsWithChars: String?, position: DeputyPosition?, current: Bool?)
    case federalSubject(current: Bool?)
    case regionalSubject(current: Bool?)
    case instances(current: Bool?)

    private var method: HTTPMethod {
        return .get
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
        }
    }

    private var parameters: Parameters {
        var dict = ["app_token": appToken()]

        switch self {

        case let .search(bill):
            var billParameters = RequestRouter.forgeBillRequestParameters(forQuery: bill)
            billParameters["app_token"] = appToken()
            return billParameters

        case let .deputy(beginsWithChars, position, current):
            if let initialChars = beginsWithChars {
                dict["begin"] = initialChars
            }
            if let deputyPosition = position {
                dict["position"] = deputyPosition.rawValue
            }
            if let isDepuyCurrent = current {
                dict["current"] = isDepuyCurrent ? "1" : "0"
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
        let apikey: String = apiKey()
        let url = try RequestRouter.baseUrl.asURL().appendingPathComponent(apikey)
        let urlRequest = URLRequest(url: url.appendingPathComponent(path))
        let request =  try URLEncoding.default.encode(urlRequest, with: parameters)
        debugPrint("Request Router forged a request \(request)")
        return request
    }

    // MARK: - Private API and app keys

    internal func appToken() -> String {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let token = dict["appToken"] as? String {
                return token
            }
        }
        fatalError("Cannot get app key from Keys.plist")
    }

    private func apiKey() -> String {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let key = dict["apiKey"] as? String {
                return key
            }
        }
        fatalError("Cannot get API key from Keys.plist")
    }
}
