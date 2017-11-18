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
    var downloadingAttachments = Set<String>()


    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doPreinstallation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachedDocumentCellId", for: indexPath) as! AttachmentTableViewCell
        cell.billTitle.text = event!.attachmentsNames[indexPath.row]
        setCellDownloadImageAndLabel(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let downloadLink = event?.attachments[indexPath.row],
            let billNr = billNumber, let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if UserServices.pathForDownloadAttachment(forBillNumber: billNumber!, withLink: downloadLink) != nil {
            previewCellContent(withDownloadLink: downloadLink, billNr: billNr)
        } else {
            // Attachment is not being already downloaded
            if !downloadingAttachments.contains(downloadLink) {
                downloadingAttachments.insert(downloadLink)
                downloadAttachment(forCell: cell as! AttachmentTableViewCell, billNr: billNr, downloadLink: downloadLink)
            }
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
        return UserServices.pathForDownloadAttachment(forBillNumber: billNumber!, withLink: (event?.attachments[indexPath.row])!) != nil
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
    
    func downloadAttachment(forCell cell: AttachmentTableViewCell, billNr: String, downloadLink: String) {
        UserServices.downloadAttachment(forBillNumber: billNr, withLink: downloadLink, updateProgressStatus: { (progressValue) in
            DispatchQueue.main.async {
                let percent = progressValue * 100
                cell.infoLabel?.text = String(format: "Документ загружается: %2.1f%%", percent)
            }
            
            }, completion: { [weak self] in
                self?.downloadingAttachments.remove(downloadLink)
                DispatchQueue.main.async {
                    if let indexPath = self?.tableView.indexPath(for: cell) {
                        self?.setCellDownloadImageAndLabel(cell: cell, atIndexPath: indexPath)
                    }
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
    
    func setCellDownloadImageAndLabel(cell: AttachmentTableViewCell, atIndexPath indexPath: IndexPath) {
        if let existingPath = UserServices.pathForDownloadAttachment(forBillNumber: billNumber!, withLink: (event?.attachments[indexPath.row])!) {
            cell.infoLabel.text = "Документ загружен (\(FilesManager.sizeOfFile(atPath: existingPath) ?? ""))"
            switch URL(fileURLWithPath: existingPath).pathExtension.lowercased() {
            case "doc", "docx":
                cell.docTypeImage.image = #imageLiteral(resourceName: "file_doc")
            case "xls", "xlsx":
                cell.docTypeImage.image = #imageLiteral(resourceName: "file_xls")
            case "pdf":
                cell.docTypeImage.image = #imageLiteral(resourceName: "file_pdf")
            case "ppt", "pptx":
                cell.docTypeImage.image = #imageLiteral(resourceName: "file_ppt")
            case "rtf":
                cell.docTypeImage.image = #imageLiteral(resourceName: "file_rtf")
            default:
                cell.docTypeImage.image = #imageLiteral(resourceName: "file_unknown")
            }
        } else {
            cell.docTypeImage.image = #imageLiteral(resourceName: "file_download")
            cell.infoLabel.text = "Документ не загружен"
        }
    }

}
