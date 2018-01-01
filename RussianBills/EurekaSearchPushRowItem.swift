//
//  EurekaSearchPushRowItem.swift
//  RussianBills
//
//  Created by Xan Kraegor on 01.01.2018.
//  Copyright © 2018 Xan Kraegor. All rights reserved.
//

import Foundation

public protocol SearchPushRowItem {
    func matchesSearchQuery(_ query: String) -> Bool
}
