//
//  TopicsTableViewControllerSelector.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

enum SimpleTableViewControllerSelector: String {
    case topics
    case lawClasses
    case committees
    case federalSubjects
    case regionalSubjects

    var description: String {
        return self.rawValue
    }

    var fullDescription: String {
        switch self {
        case .lawClasses:
            return "Отрасли зконодательства"
        case .topics:
            return "Тематические блоки"
        case .committees:
            return "Комитеты ГД РФ"
        case .federalSubjects:
            return "Федеральные органы власти ОПЗИ"
        case .regionalSubjects:
            return "Региональные органы власти ОПЗИ"
        }
    }

    var typeUsedForObjects: Object.Type {
        switch self {
        case .lawClasses:
            return LawClass_.self
        case .topics:
            return Topic_.self
        case .committees:
            return Comittee_.self
        case .federalSubjects:
            return FederalSubject_.self
        case .regionalSubjects:
            return RegionalSubject_.self
        }
    }
}
