//
//  Dispatcher.swift
//  RussianBills
//
//  Created by Xan Kraegor on 19.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class Dispatcher {
    // Singletone
    static let shared = Dispatcher()

    let referenceDownloadDispatchGroup = DispatchGroup()
    let referenceDownloadDispatchQueue = DispatchQueue(label: "referenceDownloadDispatchQueue", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)

    init() {
        debugPrint("Dispatcher Initialization")
        
    }
}
