//
//  SettingsTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 25.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import SafariServices

final class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var iCloudSyncEngineSwitch: UISwitch!
    @IBOutlet weak var downloadedFilesSizeLabel: UILabel?
    @IBOutlet weak var downloadedAttachmentsDeleteCell: UITableViewCell?
    @IBOutlet weak var updateBillsTimeoutSlider: UISlider?
    @IBOutlet weak var sliderTimeLabel: UILabel?
    @IBOutlet weak var switchKeysButton: UIButton?
    @IBOutlet weak var switchKeysStatusLabel: UILabel?
    @IBOutlet weak var devVersionLabel: UILabel!

    private let sliderValues: [Double] = [300, 900, 3600, 7200, 18000] // TimeInterval in seconds
    private let sliderValuesDescription: [String] = ["5 мин.", "15 мин.", "1 час", "2 часа", "5 часов"]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        tableView.delegate = self
        setSizeLabelText()


        if let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let buildVer = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            devVersionLabel.text = "Разработчик: Антон Алексеев\n© 2017 XanKraegor\nВерсия \(shortVer) (\(buildVer))"
        }
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

        updateKeysCells()
        iCloudSyncEngineSwitch.isOn = UserDefaultsCoordinator.iCloudSyncTurnedOn
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Удалить все загруженные файлы
        if indexPath.section == 4 && indexPath.row == 1 {
            deleteAttachmentsDialog()
        }

        if indexPath.section == 5 && indexPath.row == 1 { // About link to github
            presentSafariWithUrl("https://github.com/xankraegor/RussianBills")
        }

        if indexPath.section == 6 {
            switch indexPath.row {
            case 0:
                presentSafariWithUrl("http://api.duma.gov.ru/")
            case 1:
                presentSafariWithUrl("https://github.com/Alamofire/Alamofire/blob/master/LICENSE")
            case 2:
                presentSafariWithUrl("http://try.crashlytics.com/terms/terms-of-service.pdf")
            case 3:
                presentSafariWithUrl("https://github.com/tid-kijyun/Kanna/blob/master/LICENSE")
            case 4:
                presentSafariWithUrl("https://github.com/realm/realm-cocoa/blob/master/LICENSE")
            case 5:
                presentSafariWithUrl("https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE")
            case 6:
                presentSafariWithUrl("https://www.flaticon.com/packs/files-8")
            case 7:
                presentSafariWithUrl("https://icons8.com/color-icons")
            default:
                break
            }
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

    // MARK: - iCloud Sync Switch

    @IBAction func iCloudSyncSwitchValueChanged(_ sender: UISwitch) {

        if FileManager.default.ubiquityIdentityToken != nil {
            // If iCloud is on
            if sender.isOn {

                sender.isEnabled = false

                SyncMan.shared.iCloudSyncEngine?.startAnew() { (successful, message) in
                    if successful {
                        sender.isEnabled = true
                        UserDefaultsCoordinator.iCloudSyncTurnedOn = true
                    } else {
                        sender.isEnabled = true
                        UserDefaultsCoordinator.iCloudSyncTurnedOn = false

                        let alert = UIAlertController(title: "Ошибка синхронизации", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertActionStyle.default))
                        self.present(alert, animated: true, completion: { [weak sender] in
                            sender?.setOn(false, animated: true)
                        })
                    }
                }
            } else {
                // To be sure it's not being called from 'sender.isOn = false' a couple of lines before
                if UserDefaultsCoordinator.iCloudSyncTurnedOn {
                    UserDefaultsCoordinator.iCloudSyncTurnedOn = false
                    SyncMan.shared.iCloudSyncEngine?.stop()
                }
            }
        } else {
            // Set previous value and tell user that it can't be changed as long as iCloud is unreachable
            let alert = UIAlertController(title: "Синхронизация", message: "Невозможно \(sender.isOn ? "включить" : "выключить") синхронизацию с iCloud, так как iCloud недоступен, выключен или запрещен системными настройками.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertActionStyle.default))
            present(alert, animated: true, completion: { [weak sender] in
                sender?.setOn(false, animated: true)
            })
        }
    }

    // MARK: - Helper functions

    func setSizeLabelText() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            let size = FilesManager.sizeOfDirectoryContents(atPath: documentsDirectory) ?? "0 байт"
            downloadedFilesSizeLabel?.text = "Загруженные приложения к законопроектам занимают \(size)"
        }
    }

    // MARK: - Custom Keys

    @IBAction func switchKeysButtonPressed(_ sender: Any) {
        let usingCustomKeys = UserDefaultsCoordinator.getUsingCustomKeys()
        if usingCustomKeys {
            // Reset keys to default
            UserServices.resetToDefaultApiKeys()
            updateKeysCells()
            let alert = UIAlertController(title: "Используются системные ключи", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertActionStyle.default))
            present(alert, animated: true, completion: nil)
        } else {
            // Setup new keys

            let alert = UIAlertController(title: "Введите полученные ключи", message: "", preferredStyle: UIAlertControllerStyle.alert)

            alert.addTextField(configurationHandler: { (textField: UITextField!) in
                textField.placeholder = "Ключ API"
            })

            alert.addTextField(configurationHandler: { (textField: UITextField!) in
                textField.placeholder = "Ключ приложения"
            })


            let actionCancel = UIAlertAction(title: "Отменить", style: UIAlertActionStyle.default, handler: nil)

            let actionDone = UIAlertAction(title: "Применить", style: UIAlertActionStyle.default) { [weak self] _ in
                guard let inputApiKey = alert.textFields?[0].text, let inputAppKey = alert.textFields?[1].text else {
                    return
                }
                UserServices.setupCustomApiKeys(apiKey: inputApiKey, appToken: inputAppKey, completionMessage: {
                    (passing, message) in
                    let alert = UIAlertController(title: passing ? "Успешно" : "Ошибка", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: UIAlertActionStyle.default))
                    self?.present(alert, animated: true) {
                        [weak self] in
                        self?.updateKeysCells()
                    }
                })
            }

            alert.addAction(actionCancel)
            alert.addAction(actionDone)

            present(alert, animated: true, completion: nil)
        }
    }


    func updateKeysCells() {
        if UserDefaultsCoordinator.getUsingCustomKeys() {
            switchKeysButton?.setTitle("Использовать ключи приложения", for: UIControlState.normal)
            switchKeysStatusLabel?.text = "Сейчас исп.: свои ключи"
        } else {
            switchKeysButton?.setTitle("Использовать свои ключи", for: UIControlState.normal)
            switchKeysStatusLabel?.text = "Сейчас исп.: ключи приложения"
        }
    }

    @IBAction func getCustomKeysButtonPressed(_ sender: Any) {
        presentSafariWithUrl("http://api.duma.gov.ru/key-request")
    }

    func presentSafariWithUrl(_ url: String) {
        if let url = URL(string: url) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }

    func deleteAttachmentsDialog() {

        let alert = UIAlertController(title: "Удаление сохраненных вложений", message: "Все загруженные документы, приложенные к законопроекам, будут удалены. Их можно загрузить повторно. Продолжить? ", preferredStyle: UIAlertControllerStyle.alert)

        let actionCancel = UIAlertAction(title: "Отменить", style: UIAlertActionStyle.default, handler: nil)
        let actionDone = UIAlertAction(title: "Удалить", style: UIAlertActionStyle.destructive) { [weak self] _ in
            FilesManager.deleteAllAttachments()
            self?.setSizeLabelText()
        }

        alert.addAction(actionCancel)
        alert.addAction(actionDone)
        present(alert, animated: true, completion: nil)
    }

}
