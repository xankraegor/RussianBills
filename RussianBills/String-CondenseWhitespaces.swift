//
//  String-CondenseWhitespaces.swift
//  RussianBills
//
//  Created by Xan Kraegor on 09.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension String {

    func prettify(noQuotes: Bool = false) -> String {
        let output = self
                .components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                .filter {
                    !$0.isEmpty
                }
                .joined(separator: " ")
        if noQuotes {
            return output
        } else {
            let quotesOutput = output
                    .replacingOccurrences(of: " \"", with: " «")
                    .replacingOccurrences(of: "\"", with: "»")
            if quotesOutput.first == "»" {
                return "«" + quotesOutput.dropFirst()
            } else {
                return quotesOutput
            }
        }
    }

}
