//
//  RegionalSubject.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Список федеральных органов власти, обладающих ПЗИ
final class RegionalSubject_: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var isCurrent: Bool = false
    @objc dynamic var startDate: String = ""
    @objc dynamic var stopDate: String = ""

    convenience init(__withFakeName name: String) {
        self.init()
        self.name = name
    }

    override static func primaryKey() -> String {
        return "id"
    }

}

// MARK: - InitializableWithJson
extension RegionalSubject_: InitializableWithJson {

    convenience init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        isCurrent = json["isCurrent"].boolValue
        startDate = json["startDate"].stringValue
        stopDate = json["stopDate"].stringValue
    }

}

// MARK: - QuickSearchFieldsReporting
extension RegionalSubject_: QuickSearchFieldsReporting {

    static var searchFields = ["name"]
    static var hasIsCurrent = true

}


// MARK: - Eureka's Search Push Row Item
extension RegionalSubject_: SearchPushRowItem {
    
    func matchesSearchQuery(_ query: String) -> Bool {
        return name.range(of: query, options: .caseInsensitive, locale: Locale.init(identifier: "ru_RU")) != nil
    }
    
}

