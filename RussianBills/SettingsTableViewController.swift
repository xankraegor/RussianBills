//
//  SettingsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 25.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var downloadedFilesSizeLabel: UILabel!

    @IBOutlet weak var downloadedAttachmentsDeleteCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        setSizeLabelText()
        tableView.delegate = self
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Удалить все загруженные файлы
        if indexPath.section == 0 && indexPath.row == 1 {
            FilesManager.deleteAllAttachments()
            setSizeLabelText()
        }

    }

    // MARK: - Helper functions

    func setSizeLabelText () {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        let size = FilesManager.sizeOfDirectoryContents(atPath: documentsDirectory) ?? "0 байт"
        downloadedFilesSizeLabel.text = "Загруженные приложения к законопроектам занимают \(size)"
        
    }



}
