//
//  BillParserContent.swift
//  RussianBills
//
//  Created by Xan Kraegor on 26.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

struct BillParserContent: Codable {
    var phases: [BillParserPhase] = []

    func serialize() -> Data? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return data
    }

    static func deserialize(data: Data) -> BillParserContent? {
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(self, from: data) else {
            return nil
        }
        return decoded
    }
}
