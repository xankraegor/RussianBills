//
//  Dispatcher.swift
//  RussianBills
//
//  Created by Xan Kraegor on 19.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

final class Dispatcher {
    // Singleton
    static let shared = Dispatcher()
    private init() {}

    // Queues and groups
    let referenceDownloadDispatchGroup = DispatchGroup()
    let referenceDownloadDispatchQueue = DispatchQueue(label: "referenceDownloadDispatchQueue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent)

    let billsDownloadDispatchGroup = DispatchGroup()
    let billsDownloadDispatchQueue = DispatchQueue(label: "billsDownloadDispatchQueue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent)

    let attachmentsDownloadQueue = DispatchQueue(label: "attachmentsDownloadQueue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent)

    let favoritesUpdateDispatchGroup = DispatchGroup()
    let billsPrefetchDispatchQueue = DispatchQueue(label: "billsPrefetchDispatchQueue", qos: .utility, attributes: DispatchQueue.Attributes.concurrent)

    let htmlParseQueue = DispatchQueue(label: "html-parse-queue", qos: .userInitiated)
    var prefetchBillsWorkItem: DispatchWorkItem?

    var favoriteBillsUpdateTimer: DispatchSourceTimer?

    // Dispatcher Functions

    func dispatchReferenceDownload(with: @escaping ()->Void) {
        DispatchQueue.global().async(group: Dispatcher.shared.referenceDownloadDispatchGroup) {
            with()
        }
    }

    func dispatchBillsPrefetching(afterSeconds: Double, block: @escaping ()->Void) {
        prefetchBillsWorkItem?.cancel()
        billsPrefetchDispatchQueue.asyncAfter(deadline: DispatchTime.now() + afterSeconds) {
            block()
        }
    }

}
