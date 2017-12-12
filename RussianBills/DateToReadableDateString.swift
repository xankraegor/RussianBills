//
//  DateToReadableDateString.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension Date {
    public func toReadableString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy 'г. в' HH:mm:ss zzz"

        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: self)
    }
}
