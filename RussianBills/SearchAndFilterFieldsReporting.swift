//
//  SearchAndFilterFieldsReporting.swift
//  RussianBills
//
//  Created by Xan Kraegor on 26.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

protocol SortAndFilterFieldsReporting {
    static var sortFields: [String] { get }
    static var filterFields: [String] { get }
}
