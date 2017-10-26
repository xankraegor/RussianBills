//
//  BillParserEvent.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

struct BillParserEvent: Codable {
    
    var name: String
    var date: String?
    var docNr: String?
    var attachments: [String] = []
    var attachmentsNames: [String] = []
    
    init(withName name: String, date: String?, docNr: String? = nil) {
        self.name = name
        self.date = date
        self.docNr = docNr
    }
    
}
