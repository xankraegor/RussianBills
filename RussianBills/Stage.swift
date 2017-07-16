//
//  Stage.swift
//  RussianBills
//
//  Created by Xan Kraegor on 11.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Cтадии рассмотрения
final class Stage_: Object, InitializableWithJson {
    dynamic var id: Int = 0
    dynamic var name: String = ""
//    dynamic var phases: [Phase] = []

    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
//        let phases = json["phases"].arrayValue

    }

    override static func primaryKey() -> String {
        return "id"
    }
}
