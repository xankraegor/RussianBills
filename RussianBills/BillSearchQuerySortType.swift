//
//  BillSearchQuerySortType.swift
//  RussianBills
//
//  Created by Xan Kraegor on 05.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

enum BillSearchQuerySortType: String, CustomStringConvertible {
    case name
    case number
    case date
    case date_asc
    case last_event_date
    case last_event_date_asc
    case responsible_committee

    var description: String {
        get {
            switch self {
            // Сортировать по:
            case .name: return "названию законопроекта"
            case .number: return "номеру законопроекта"
            case .date: return "дате внесения в ГД (по убыванию)"
            case .date_asc: return "дате внесения в ГД (по возрастанию)"
            case .last_event_date: return "дате последнего события (по убыванию)"
            case .last_event_date_asc: return "дате последнего события (по возрастанию)"
            case .responsible_committee: return "ответственному комитету"
            }
        }
    }

    static let allValues = [name, number, date, date_asc, last_event_date, last_event_date_asc, responsible_committee]
}
