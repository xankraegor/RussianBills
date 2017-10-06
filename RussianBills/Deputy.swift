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
final class Deputy_: Object, InitializableWithJson, SortAndFilterFieldsReporting {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var position: String = ""
    @objc dynamic var isCurrent: Bool = false

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        position = json["position"].stringValue
        isCurrent = json["isCurrent"].boolValue
    }
    
    static var sortFields: [String] {
        return ["name", "isCurrent", "position"]
    }
    
    static var filterFields: [String] {
        return ["isCurrent", "position"]
    }

    override static func primaryKey() -> String {
        return "id"
    }
}
