//
//  BillAttachedDocumentsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 21.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import QuickLook

final class BillAttachedDocumentsTableViewController: UITableViewController, QLPreviewControllerDataSource {

    var event: BillParserEvent?
    var billNumber: String?
    var previewItemUrlString: String? = nil


    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doPreinstallation()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event!.attachments.count
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachedDocumentCellId", for: indexPath)
        cell.textLabel?.text = event!.attachmentsNames[indexPath.row]
        let attachmentAlreadyDownloaded = UserServices.isAttachmentDownloaded(forBillNumber: billNumber!, withLink: (event?.attachments[indexPath.row])!)
        cell.detailTextLabel?.text = attachmentAlreadyDownloaded ? "📦 Документ загружен" :  "🌐 Документ не загружен"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let downloadLink = event?.attachments[indexPath.row],
            let billNr = billNumber, let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if UserServices.isAttachmentDownloaded(forBillNumber: billNumber!, withLink: downloadLink) {
            previewCellContent(withDownloadLink: downloadLink, billNr: billNr)
        } else {
            downloadAttachment(forCell: cell, billNr: billNr, downloadLink: downloadLink)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let key = FilesManager.extractUniqueDocumentNameFrom(urlString: (event?.attachments[indexPath.row]) ?? "") {
                UserServices.deleteAttachment(usingKey: key, forBillNr: billNumber!)
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return UserServices.isAttachmentDownloaded(forBillNumber: billNumber!, withLink: (event?.attachments[indexPath.row])!)
    }

    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        if previewItemUrlString != nil {
            return 1
        }
        return 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return URL(fileURLWithPath: previewItemUrlString!) as QLPreviewItem
    }


    // MARK: - Helper functions

    func previewCellContent(withDownloadLink downloadLink: String, billNr: String) {
        previewItemUrlString = FilesManager.pathForFile(containingInName: FilesManager.extractUniqueDocumentNameFrom(urlString: downloadLink)!, inDirectory: FilesManager.attachmentDir(forBillNumber: billNr))
        let qpController = QLPreviewController()
        qpController.dataSource = self
        show(qpController, sender: nil)
    }

    func downloadAttachment(forCell cell: UITableViewCell, billNr: String, downloadLink: String) {
        UserServices.downloadAttachment(forBillNumber: billNr, withLink: downloadLink, updateProgressStatus: { (progressValue) in
            if progressValue < 1 {
                DispatchQueue.main.async {
                    let percent = progressValue * 100
                    cell.detailTextLabel?.text = String(format: "⬇️ Документ загружается: %2.1f%%", percent)
                }
            } else {
                cell.detailTextLabel?.text = "📦 Документ загружен"
            }
        })
    }

    func doPreinstallation() {
        guard event != nil else {
            fatalError("No event handed to the UITableViewController")
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        if let navigationTitle = billNumber {
            self.navigationItem.title = "Документы 📃\(navigationTitle)"
        }
    }
}
