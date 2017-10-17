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
        if let namePart = FilesManager.extractUniqueDocumentNameFrom(urlString: event!.attachments[indexPath.row]), let billString = billNumber {
            let documentDownloaded = FilesManager.doesFileExist(withNamePart: namePart, atRelativePath: "/\(billString))/Attachments/")
            cell.detailTextLabel?.text = documentDownloaded ? "\n📦 Документ загружен" :  "\n🌐 Документ не загружен"
        } else {
            cell.detailTextLabel?.text = "🌐 Документ не загружен"
        }
//        print(event!.attachments[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let linkString = event?.attachments[indexPath.row], let billString = billNumber,
            let namePart = FilesManager.extractUniqueDocumentNameFrom(urlString: event!.attachments[indexPath.row]) {
            let cell = tableView.cellForRow(at: indexPath)

            let documentAlreadyDownloaded = FilesManager.doesFileExist(withNamePart: namePart, atRelativePath: "/\(billString)/Attachments/")

            if !documentAlreadyDownloaded {
                UserServices.downloadDocument(usingRelativeLink: linkString, toDestination: "/\(billString)/Attachments/",
                    updateProgressStatus: { (progressValue) in
                        if progressValue < 1 {
                            cell?.detailTextLabel?.text = "\n⬇️ Документ загружается: \(progressValue * 100)%"
                        } else {
                            cell?.detailTextLabel?.text = "\n📦 Документ загружен"
                        }
                }, fileURL: { (filePath) in
                    // TODO: Preview downloaded file
                    print(filePath)
                })
            }
        } else {
            debugPrint("∆ Can not get name part")
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
