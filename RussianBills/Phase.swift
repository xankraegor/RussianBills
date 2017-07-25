//
//  Phase.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Фазы рассмотрения
final class Phase_: Object, InitializableWithJson {
    dynamic var id: Int = 0
    dynamic var name: String = ""

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
    }
    
    static var fields: [String] {
        return ["name"]
    }


    override static func primaryKey() -> String {
        return "id"
    }
}
