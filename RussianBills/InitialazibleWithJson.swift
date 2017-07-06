//
//  InitialazibleWithJson.swift
//  RussianBills
//
//  Created by Xan Kraegor on 04.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol InitializableWithJson {
    init(withJson json: JSON)
}
