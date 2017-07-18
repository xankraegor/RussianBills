//
//  BillParserEvent.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

struct BillParserEvent {

    var name: String
    var date: Date
    var docNr: String?
    var attachments: [URL] = []
    
    init(withName name: String, date: Date, docNr: String? = nil, attachments: [URL]) {
        self.name = name
        self.date = date
        self.docNr = docNr
        self.attachments = attachments
    }
    
}
