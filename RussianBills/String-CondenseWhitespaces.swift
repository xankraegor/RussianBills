//
//  String-CondenseWhitespaces.swift
//  RussianBills
//
//  Created by Xan Kraegor on 09.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension String {

    func prettify() -> String {
        let output = self
            .components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .replacingOccurrences(of: " \"", with: " «")
            .replacingOccurrences(of: "\"", with: "»")
        if output.first == "»" {
            return "«" + output.dropFirst()
        } else {
            return output
        }
    }

}
