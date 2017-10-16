//
//  Instances.swift
//  RussianBills
//
//  Created by Xan Kraegor on 11.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Список инстанций рассмотрения
final class Instance_: Object, InitializableWithJson, QuickSearchFieldsReporting {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var isCurrent: Bool = false

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        isCurrent = json["isCurrent"].boolValue
    }

    override static func primaryKey() -> String {
        return "id"
    }

    // MARK: - QuickSearchFieldsReporting

    static var searchFields = ["name"]
}
