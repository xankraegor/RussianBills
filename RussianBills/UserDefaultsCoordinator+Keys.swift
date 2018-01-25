//
//  UserDefaultsCoordinator+Keys.swift
//  RussianBills
//
//  Created by Xan Kraegor on 12.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension UserDefaultsCoordinator {

    // MARK: - Default Keys

    static func appToken() -> String {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let token = dict["appToken"] as? String {
                return token
            }
        }
        fatalError("Cannot get app key from Keys.plist")
    }

    static func apiKey() -> String {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let key = dict["apiKey"] as? String {
                return key
            }
        }
        fatalError("Cannot get API key from Keys.plist")
    }

    // MARK: - Custom Keys

    static func getUsingCustomKeys()-> Bool {
        return UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.bool(forKey: "isUsingCustomKeys")
    }

    static func setUsingCustomKeys(to value: Bool) {
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(value, forKey: "isUsingCustomKeys")
    }

    static func customApiKeys()-> (apiKey: String, appToken: String)? {
        if let customApiKey = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.string(forKey: "customApiKey"),
            let customAppToken = UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.string(forKey: "customAppToken") {
            return (customApiKey, customAppToken)
        } else {
            return nil
        }
    }

    static func setCustomKeys(apiKey: String, appToken: String) {
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(apiKey, forKey: "customApiKey")
        UserDefaults(suiteName: UserDefaultsCoordinator.suiteName)!.set(appToken, forKey: "customAppToken")
    }

}
