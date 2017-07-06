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

    case federalLaw = 38
    case federalConstitionalLaw = 39
    case constitutionalAmendment = 41

    var description: String {
        get {
            switch self {
            case .federalLaw:
                return "Федеральный закон"
            case .federalConstitionalLaw:
                return "Федеральный конституционный закон"
            case .constitutionalAmendment:
                return "Закон о поправках к Конституции РФ"
            }
        }
    }

    var id: Int {
        return self.rawValue
    }

}
