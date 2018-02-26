//
//  Deputy.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Список депутатов Госдумы и членов Совета Федерации
final class Deputy_: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var position: String = ""
    @objc dynamic var isCurrent: Bool = false

    convenience init(withFakeName name: String) {
        self.init()
        self.name = name
    }

    override static func primaryKey() -> String {
        return "id"
    }

}

// MARK: - InitializableWithJson
extension Deputy_: InitializableWithJson {

    convenience init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        position = json["position"].stringValue
        isCurrent = json["isCurrent"].boolValue
    }

}

// MARK: - QuickSearchFieldsReporting
extension Deputy_: QuickSearchFieldsReporting {

    static var searchFields = ["name", "position"]
    static var hasIsCurrent = true

}

// MARK: - Eureka's Search Push Row Item
extension Deputy_: SearchPushRowItem {

    func matchesSearchQuery(_ query: String) -> Bool {
        return name.range(of: query, options: .caseInsensitive, locale: Locale.init(identifier: "ru_RU")) != nil
    }

}
