//
//  String-CondenseWhitespaces.swift
//  RussianBills
//
//  Created by Xan Kraegor on 09.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
