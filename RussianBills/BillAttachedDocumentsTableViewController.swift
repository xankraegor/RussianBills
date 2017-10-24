//
//  BillAttachedDocumentsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 21.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class BillAttachedDocumentsTableViewController: UITableViewController {
    
    var event: BillParserEvent?
    var billNumber: String?
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        if event == nil {
            fatalError("No event handed to the UITableViewController")
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        if let navigationTitle = billNumber {
            self.navigationItem.title = "Документы 📃\(navigationTitle)"
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event!.attachments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachedDocumentCellId", for: indexPath)
        cell.textLabel?.text = event!.attachmentsNames[indexPath.row]

        let attachmentAlreadyDownloaded = UserServices.isAttachmentDownloaded(forBillNumber: billNumber!, withLink: (event?.attachments[indexPath.row])!)
        cell.detailTextLabel?.text = attachmentAlreadyDownloaded ? "\n📦 Документ загружен" :  "\n🌐 Документ не загружен"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let downloadLink = event?.attachments[indexPath.row],
            let billNr = billNumber, let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let attachmentAlreadyDownloaded = UserServices.isAttachmentDownloaded(forBillNumber: billNumber!, withLink: downloadLink)

        if attachmentAlreadyDownloaded {
            // TODO: When downloaded - open!
            debugPrint("∆ Attachment for bill \(billNr) already downloaded with link \(downloadLink)")
        } else { // Download it and do something with fileUrl

            UserServices.downloadAttachment(forBillNumber: billNr, withLink: downloadLink, updateProgressStatus: { (progressValue) in
                if progressValue < 1 {
                    cell.detailTextLabel?.text = "\n⬇️ Документ загружается: \(progressValue * 100)%"
                } else {
                    cell.detailTextLabel?.text = "\n📦 Документ загружен"
                }
            }, fileURL: { (filePath) in
                // TODO: Open it now?
                debugPrint("∆ Downloaded file path is \(filePath)")
            })

        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
