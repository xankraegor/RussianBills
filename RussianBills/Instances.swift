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
final class Instance_: Object, InitializableWithJson, SortAndFilterFieldsReporting {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var isCurrent: Bool = false

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        isCurrent = json["isCurrent"].boolValue
    }
    
    static var sortFields: [String] {
        return ["name", "isCurrent"]
    }
    
    static var filterFields: [String] {
        return ["isCurrent"]
    }

    override static func primaryKey() -> String {
        return "id"
    }
}
