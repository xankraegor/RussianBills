//
//  BillCardTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Kanna
import RealmSwift
import SafariServices

final class BillCardTableViewController: UITableViewController {
    let realm = try? Realm()

    @IBOutlet weak var billTypeLabel: UILabel?
    @IBOutlet weak var billTitle: UILabel?
    @IBOutlet weak var billCommentsLabel: UILabel?

    @IBOutlet weak var introductionDateLabel: UILabel?
    @IBOutlet weak var introducedByLabel: UILabel?

    @IBOutlet weak var lastEventStageLabel: UILabel?
    @IBOutlet weak var lastEventPhaseLabel: UILabel?
    @IBOutlet weak var lastEventDecisionLabel: UILabel?
    @IBOutlet weak var lastEventDateLabel: UILabel?
    @IBOutlet weak var lastEventDocumentLabel: UILabel?

    @IBOutlet weak var moreDocsLabel: UILabel?
    @IBOutlet weak var moreDocsIndicator: UIActivityIndicatorView?
    @IBOutlet weak var moreDocsCell: UITableViewCell?

    @IBOutlet weak var noteLabel: UILabel!

    @IBOutlet weak var respCommitteeLabel: UILabel?
    @IBOutlet weak var coexecCommitteeLabel: UILabel?
    @IBOutlet weak var profileComitteesLabel: UILabel?

    var billNr: String?

    lazy var bill: Bill_? = {
        return realm?.object(ofType: Bill_.self, forPrimaryKey: billNr)
    }()

    lazy var favoriteBill: FavoriteBill_? = {
        return realm?.object(ofType: FavoriteBill_.self, forPrimaryKey: billNr)
    }()

    var parser: BillParser? {
        didSet {
            if let currentBill = bill, let tree = parser?.tree {
                UserServices.setParserContent(ofBillNr: currentBill.number, to: tree)
            }
        }
    }

    var realmNotificationToken: NotificationToken?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        installRealmToken()
        tableView.delegate = self
        if favoriteBill?.favoriteHasUnseenChanges ?? false {
            try? realm?.write {
                favoriteBill?.favoriteHasUnseenChanges = false
            }
            UIApplication.shared.applicationIconBadgeNumber -= 1
            print("num: \(UIApplication.shared.applicationIconBadgeNumber)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
        fetchExistingBillData()
        if let currentBill = bill {
            if currentBill.parserContent != nil {
                activateMoreInfoCell()
            }
        }

        beginStagesParsing()
        reloadCurrentBillData()
    }

    deinit {
        realmNotificationToken?.invalidate()
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // Header
            switch indexPath.row {
            case 2: // Bill Description
                let count = bill?.comments.count ?? 0
                return count > 0 ? UITableViewAutomaticDimension : 0
            case 3...5: // Flag colors
                return 4
            default:
                return UITableViewAutomaticDimension
            }
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // Last Events Section
        if section == 1 {
            let updated = bill?.updated ?? Date.distantPast
            return "Обновлено \(updated.toReadableString())"
        }

        // Note section
        if section == 4 {
            if favoriteBill != nil {
                return ""
            } else {
                return "Добавьте законопроект в отслеживаемые для добавления заметки"
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        // Note section
        if section == 4 {
            if favoriteBill != nil {
                return 2
            } else {
                return 0
            }
        } else {
            return count
        }
    }

    // MARK: - Helper functions

    private func fetchExistingBillData() {
        if let bill = bill {
            navigationItem.title = bill.favorite ? "№ \(bill.number) 🎖" : " № \(bill.number)"
            billTypeLabel?.text = bill.lawType.description
            billTitle?.text = bill.name
            billCommentsLabel?.text = bill.comments

            introductionDateLabel?.text = bill.introductionDate
            introducedByLabel?.text = bill.generateSubjectsDescription()

            lastEventStageLabel?.text = bill.lastEventStage?.name
            lastEventPhaseLabel?.text = bill.lastEventPhase?.name
            lastEventDecisionLabel?.text = bill.generateSolutionDescription()
            lastEventDateLabel?.text = bill.generateLastEventDateDescription()
            lastEventDocumentLabel?.text = bill.generateLastEventDocumentDescription()

            respCommitteeLabel?.text = (bill.committeeResponsible?.name.count ?? 0 > 0) ? bill.committeeResponsible?.name : "Не указан"
            profileComitteesLabel?.text = bill.generateProfileCommitteesDescription()
            coexecCommitteeLabel?.text = bill.generateCoexecitorCommitteesDescription()

            if let note = favoriteBill?.displayedNote {
                noteLabel.text = note
                noteLabel.textColor = UIColor.black
            } else {
                noteLabel.text = "Заметка отсутствует"
                noteLabel.textColor = UIColor.gray
            }

            tableView.reloadData()
        } else if let favbill = favoriteBill {
            navigationItem.title = "№ \(favbill.number) 🎖"
            billTitle?.text = favbill.name
            billCommentsLabel?.text = favbill.comments

            if let note = favoriteBill?.displayedNote {
                noteLabel.text = note
                noteLabel.textColor = UIColor.black
            } else {
                noteLabel.text = "Заметка отсутствует"
                noteLabel.textColor = UIColor.gray
            }

            introductionDateLabel?.text = " … "
            introducedByLabel?.text = " … "

            lastEventStageLabel?.text = " … "
            lastEventPhaseLabel?.text = " … "
            lastEventDecisionLabel?.text = " … "
            lastEventDateLabel?.text = " … "
            lastEventDocumentLabel?.text = " … "

            UserServices.downloadBills(withQuery: BillSearchQuery(withNumber: favbill.number), completion: { [weak self] (bills, _) in
                DispatchQueue.main.async {
                    guard let bill = bills.first else { return }
                    self?.navigationItem.title = bill.favorite ? "№ \(bill.number) 🎖" : "№ \(bill.number)"
                    self?.billTypeLabel?.text = bill.lawType.description
                    self?.billTitle?.text = bill.name
                    self?.billCommentsLabel?.text = bill.comments

                    self?.introductionDateLabel?.text = bill.introductionDate
                    self?.introducedByLabel?.text = bill.generateSubjectsDescription()

                    self?.lastEventStageLabel?.text = bill.lastEventStage?.name
                    self?.lastEventPhaseLabel?.text = bill.lastEventPhase?.name
                    self?.lastEventDecisionLabel?.text = bill.generateSolutionDescription()
                    self?.lastEventDateLabel?.text = bill.generateLastEventDateDescription()
                    self?.lastEventDocumentLabel?.text = bill.generateLastEventDocumentDescription()

                    self?.respCommitteeLabel?.text = (bill.committeeResponsible?.name.count ?? 0 > 0) ? bill.committeeResponsible?.name : "Не указан"
                    self?.profileComitteesLabel?.text = bill.generateProfileCommitteesDescription()
                    self?.coexecCommitteeLabel?.text = bill.generateCoexecitorCommitteesDescription()

                    self?.tableView.reloadData()
                }
            })
        } else {
            fatalError("Bill is not being provided")
        }
    }

    // MARK: - Navigation 

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillDetailsSegue" {
            if let dest = segue.destination as? BillDetailsTableViewController, let content = bill?.parserContent, let number = bill?.number {
                dest.parserContent = BillParserContent.deserialize(data: content)
                dest.billNumber = number
                dest.bill = bill
            }
        }

        if segue.identifier == "noteSegueId" {
            if let dest = segue.destination as? FavoriteBillNoteViewController, let number = bill?.number {
                dest.billNr = number
            }
        }
    }

    @IBAction func unwindFromNoteController(segue: UIStoryboardSegue) {
        fetchExistingBillData()
    }

    // MARK: - AlertController

    @IBAction private func composeButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Действия с законопроектом", message: "Выберите действие", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Сохранить как текстовый файл", style: .default, handler: { [weak self] (action) in

            if let description = self?.description, let number = self?.bill?.number {
                FilesManager.createAndOrWriteToFileBillDescription(text: description, name: number, atPath: NSHomeDirectory())
            } else {
                assertionFailure("Can't generate bill description or/and get bill number to save them to a file")
            }

        }))

        alert.addAction(UIAlertAction(title: "Скопировать как текст", style: .default, handler: { [weak self] (action) in
            UIPasteboard.general.string = self?.description
        }))

        alert.addAction(UIAlertAction(title: "Скопировать ссылку", style: .default, handler: {[weak self] (action) in
            UIPasteboard.general.string = self?.bill?.url
        }))

        alert.addAction(UIAlertAction(title: "Открыть в браузере", style: .default, handler: {[weak self] (action) in
            if let urlString = self?.bill?.url, let url = URL(string: urlString) {
                let svc = SFSafariViewController(url: url)
                self?.present(svc, animated: true, completion: nil)
            }
        }))

        if let fav = bill?.favorite, let number = bill?.number {
            alert.addAction(UIAlertAction(title: fav ? "Убрать из отслеживаемых" : "Добавить в отслеживаемые", style: .default, handler: { [weak self] (action) in

                let realm = try? Realm()
                if let updBill = realm?.object(ofType: Bill_.self, forPrimaryKey: self?.bill?.number) {

                        if let existingFavoriteBill = realm?.object(ofType: FavoriteBill_.self, forPrimaryKey: updBill.number), existingFavoriteBill.markedToBeRemovedFromFavorites == false {
                            try? realm?.write {
                                existingFavoriteBill.markedToBeRemovedFromFavorites = true
                            }
                            try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: existingFavoriteBill.billSyncContainer)
                            self?.navigationItem.title = "№ \(number)"
                        } else {
                            let newFavoriteBill = FavoriteBill_(fromBill: updBill)
                            try? realm?.write {
                                realm?.add(newFavoriteBill, update: true)
                            }
                            try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: newFavoriteBill.billSyncContainer)
                            self?.navigationItem.title = "№ \(number) 🎖"
                        }
                }

            }))
        } else {
            assertionFailure("Can't unwrap optional bill to add action in share menu")
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Helper functions

    private func installRealmToken() {
        guard let currentBill = bill else {
            return
        }

        realmNotificationToken = currentBill.observe { [weak self] (_) -> Void in
            if currentBill.parserContent != nil {
                self?.activateMoreInfoCell()
            }
        }
    }

    private func activateMoreInfoCell() {
        moreDocsLabel?.text = "Все события и документы"
        moreDocsLabel?.textColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
        moreDocsIndicator?.stopAnimating()
        moreDocsCell?.accessoryType = .disclosureIndicator
        moreDocsCell?.isUserInteractionEnabled = true
    }

    private func beginStagesParsing() {
        if let billUrlString = bill?.url,
            let billUrl = URL(string: billUrlString) {
            debugPrint("BillURL: \(billUrlString)")

            Request.htmlToParse(forUrl: billUrl, completion: { (html) in
                DispatchQueue.main.async {
                    self.parser = BillParser(withHTML: html)
                }
            })
        }
    }

    private func reloadCurrentBillData() {
        if let billNumber = bill?.number {
            let searchQuery = BillSearchQuery(withNumber: billNumber)
            UserServices.downloadBills(withQuery: searchQuery, completion: {
                [weak self] (bills, totalCount) -> Void in
                if let firstBill = bills.first {
                    self?.bill = firstBill
                    self?.fetchExistingBillData()
                }
            })
        }
    }

}
