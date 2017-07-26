//
//  FederalSubject.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Список федеральных органов власти, обладающих ПЗИ
final class FederalSubject_: Object, InitializableWithJson, SortAndFilterFieldsReporting {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var isCurrent: Bool = false
    dynamic var startDate: String = ""
    dynamic var stopDate: String = ""

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        isCurrent = json["isCurrent"].boolValue
        startDate = json["startDate"].stringValue
        stopDate = json["stopDate"].stringValue
    }
    
    static var sortFields: [String] {
        return ["name", "isCurrent", "startDate", "stopDate"]
    }
    
    static var filterFields: [String] {
        return ["isCurrent"]
    }

    override static func primaryKey() -> String {
        return "id"
    }

}
