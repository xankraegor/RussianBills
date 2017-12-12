//
//  SettingsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 25.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

final class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var downloadedFilesSizeLabel: UILabel?
    @IBOutlet weak var downloadedAttachmentsDeleteCell: UITableViewCell?
    @IBOutlet weak var authStatusLabel: UILabel?
    @IBOutlet weak var updateBillsTimeoutSlider: UISlider?
    @IBOutlet weak var sliderTimeLabel: UILabel?

    private let sliderValues: [Double] = [30, 120, 300, 900, 3600] // TimeInterval in seconds
    private let sliderValuesDescription: [String] = ["30 сек.", "2 мин.", "5 мин.", "15 мин.", "1 час"]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        tableView.delegate = self
        setSizeLabelText()
        authStatusLabel?.text = SyncMan.shared.isAuthorized ? "Вход осуществлён" : "Войдите для синхронизации"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = sliderValues.index(of: UserDefaults.standard.double(forKey: "favoriteUpdateTimeout")) {
            updateBillsTimeoutSlider?.value = Float(index) + 1
            sliderTimeLabel?.text = sliderValuesDescription[index]
        } else {
            updateBillsTimeoutSlider?.value = 3
            sliderTimeLabel?.text = sliderValuesDescription[3]
        }
    }


    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Удалить все загруженные файлы
        if indexPath.section == 0 && indexPath.row == 1 {
            FilesManager.deleteAllAttachments()
            setSizeLabelText()
        }
    }


    // MARK: - Slider Changed

    @IBAction func sliderValueChanged(_ sender: Any) {
        if let sliderValue = updateBillsTimeoutSlider?.value {
            let sliderPosition = Int(sliderValue)
            UserDefaults.standard.set(sliderValues[sliderPosition - 1], forKey: "favoriteUpdateTimeout")
            sliderTimeLabel?.text = sliderValuesDescription[sliderPosition - 1]
        }

    }


    // MARK: - Helper functions

    func setSizeLabelText () {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            let size = FilesManager.sizeOfDirectoryContents(atPath: documentsDirectory) ?? "0 байт"
            downloadedFilesSizeLabel?.text = "Загруженные приложения к законопроектам занимают \(size)"
        }
    }

}
