//
//  SettingsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 25.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

final class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var downloadedFilesSizeLabel: UILabel!
    @IBOutlet weak var dataBaseSizeLabel: UILabel!
    @IBOutlet weak var downloadedAttachmentsDeleteCell: UITableViewCell!
    @IBOutlet weak var authStatusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        tableView.delegate = self
        setSizeLabelText()
        setDBSizeLabelText()
        authStatusLabel.text = SyncMan.shared.isAuthorized ? "Вход осуществлён" : "Войдите для синхронизации"
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

    func setDBSizeLabelText() {
        let path = FilesManager.defaultRealmPath().absoluteString
        print(path)
        let size = FilesManager.sizeOfFile(atPath: path) ?? "0 байт"
        dataBaseSizeLabel.text = "База данных законопроектов занимает \(size)"
    }



}
