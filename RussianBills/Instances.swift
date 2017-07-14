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
class Instance_: Object, InitializableWithJson {
        dynamic var id: Int = 0
        dynamic var name: String = ""
        dynamic var isCurrent: Bool = false

        convenience required init(withJson json: JSON) {
            self.init()
            id = json["id"].intValue
            name = json["name"].stringValue
            isCurrent = json["isCurrent"].boolValue
        }

        override static func primaryKey() -> String {
            return "id"
        }
}
