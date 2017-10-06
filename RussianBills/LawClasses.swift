//
//  LawClasses.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Отрасли законодательства
final class LawClass_: Object, InitializableWithJson, SortAndFilterFieldsReporting {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
    }
    
    static var sortFields: [String] {
        return ["name"]
    }
    
    static var filterFields: [String] {
        return []
    }

    override static func primaryKey() -> String {
        return "id"
    }
}
