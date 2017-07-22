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
    var navigationTitle: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        if event == nil {
            fatalError("No event handed to the UITableViewController")
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        if let navigationTitle = navigationTitle {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachedDocumentCellId", for: indexPath) as! BillAttachedDocumentsTableViewCell
        cell.mainTitleLabel.text = event!.attachmentsNames[indexPath.row]
        if let namePart = FilesManager.extractUniqueDocumentNameFrom(urlString: event!.attachments[indexPath.row]) {
            let documentDownloaded = FilesManager.doesFileExist(withNamePart: namePart, atPath: "/")
            cell.subtitileLabel.text = documentDownloaded ? "📦 Документ загружен" :  "🌐 Документ не загружен"
        } else {
            cell.subtitileLabel.text = "🌐 Документ не загружен"
        }
//        print(event!.attachments[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let namePart = FilesManager.extractUniqueDocumentNameFrom(urlString: event!.attachments[indexPath.row]) {
            let documentDownloaded = FilesManager.doesFileExist(withNamePart: namePart, atPath: "/")
            if !documentDownloaded {
                
            }
        } else {
            debugPrint("∆ Can not get name part")
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
