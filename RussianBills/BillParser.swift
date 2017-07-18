//
//  BillParser.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Kanna

// http://asozd2.duma.gov.ru/main.nsf/(Spravka)?OpenAgent&RN=15455-7

final public class BillParser {

    init?(withHTML html: String) {
        guard let doc = HTML(html: html, encoding: .utf8) else {
            return nil
            }
        
        let body = doc.body
        
    }
}