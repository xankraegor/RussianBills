//
//  lawType.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

// Тип законопроекта

@objc enum LawType: Int, CustomStringConvertible {

    // General cases
    case federalLaw = 38
    case federalConstitutionalLaw = 39
    case constitutionalAmendment = 41

    // Special cases
    // Default case
    case undefined = 0
    // Error case of the http://sozd.parlament.gov.ru/bill/557038-6 :
    case constitutionalAmendmentOld = 40

    var description: String {
        switch self {
        case .federalLaw:
            return "Федеральный закон"
        case .federalConstitutionalLaw:
            return "Федеральный конституционный закон"
        case .constitutionalAmendmentOld:
            return "Закон о поправках к Конституции РФ"
        case .constitutionalAmendment:
            return "Закон о поправках к Конституции РФ"
        case .undefined:
            return "Тип законопроекта не определен"
        }
    }

    var id: Int {
        return self.rawValue
    }
}
