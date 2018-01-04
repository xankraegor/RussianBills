//
//  CommitteeTableViewCellDateTextGenerator.swift
//  RussianBills
//
//  Created by Xan Kraegor on 08.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

enum NameStartEndTableViewCellDateTextGenerator {
    case startDate(isoDate: String)
    case noEndDate()
    case endDate(isoDate: String)

    func description() -> String {
        switch self {
        case let .startDate(isoDate):
            return "Дата начала полномочий: \(isoDate.isoDateToReadableDate())"

        case .noEndDate:
            return "Действует в настоящее время"
        case let .endDate(isoDate):
            return "Дата окончания полномочий: \(isoDate.isoDateToReadableDate())"
        }
    }

}
