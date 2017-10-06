//
//  Factions.swift
//  RussianBills
//
//  Created by Xan Kraegor on 25.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Список фракций госдумы
final class Factions_: Object, InitializableWithJson {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    
    convenience required init(withJson json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
}
