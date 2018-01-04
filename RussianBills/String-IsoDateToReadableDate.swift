//
//  String-IsoDateToReadableDate.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension String {
    func isoDateToReadableDate() -> String {
        guard self != "" else {
            return "Не определена"
        }
        if let date = Date.dateFromISOString(string: self) {
            return DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.none)
        }
        return self
    }
}
