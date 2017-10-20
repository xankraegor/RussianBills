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
    let referenceDownloadDispatchQueue = DispatchQueue(label: "referenceDownloadDispatchQueue", qos: .userInteractive, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    let billsPrefetchDispatchQueue = DispatchQueue(label: "billsPrefetchDispatchQueue", qos: .userInitiated)

    var prefetchBillsWorkItem: DispatchWorkItem?

    func dispatchReferenceDownload(with: @escaping ()->()) {
        DispatchQueue.global().async(group: Dispatcher.shared.referenceDownloadDispatchGroup) {
            with()
        }
    }

    func dispatchBillsPrefetching(afterSeconds: Double, block: @escaping ()->()) {
        prefetchBillsWorkItem?.cancel()
        debugPrint("∆ Dispatcher: prefetchBillsWorkItem?.cancel()")
        billsPrefetchDispatchQueue.asyncAfter(deadline: DispatchTime.now() + afterSeconds) {
            debugPrint("∆ Dispatcher: billsPrefetchDispatchQueue.asyncAfter(_ \(afterSeconds)")
            block()
        }
    }

    init() {
        debugPrint("Dispatcher Initialization")
    }
}
