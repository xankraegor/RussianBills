//
//  BillParserPhase.swift
//  RussianBills
//
//  Created by Xan Kraegor on 19.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

struct BillParserPhase: Codable {
    var name: String
    var events: [BillParserEvent] = []

    init(withName: String) {
        self.name = withName
    }
}
