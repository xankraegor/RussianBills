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

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var organizedButton: UIBarButtonItem!
    @IBOutlet weak var organizedTextButton: UIBarButtonItem!


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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        fetchExistingBillData()

        if favoriteBill?.favoriteHasUnseenChanges ?? false {
            try? realm?.write {
                favoriteBill?.favoriteHasUnseenChanges = false
            }
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }

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
        case 4:
            if let bl = bill, bl.favorite {
                return UITableViewAutomaticDimension
            } else {
                return 0
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
            if let bl = bill, bl.favorite {
                return ""
            } else {
                return "Добавьте законопроект в отслеживаемые для добавления заметки"
            }
        }
        return nil
    }

    // MARK: - Helper functions

    private func fetchExistingBillData() {
        
        if let bill = bill {
            navigationItem.title = "№ \(bill.number)"
            organizedTextButton.title = bill.favorite ? "Отслеживаемый" : ""

            tableView.beginUpdates()

            billTypeLabel?.text = bill.lawType.description
            billTitle?.text = bill.name
            billCommentsLabel?.text = bill.comments

            introductionDateLabel?.text = bill.introductionDate.isoDateToReadableDate()
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

            tableView.endUpdates()

        } else if let favbill = favoriteBill {
            organizedTextButton.title = "Отслеживаемый"

            tableView.beginUpdates()

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

            tableView.endUpdates()

            UserServices.downloadBills(withQuery: BillSearchQuery(withNumber: favbill.number), completion: { [weak self] (bills, _) in
                DispatchQueue.main.async {
                    guard let bill = bills.first else { return }

                    self?.organizedTextButton.title = bill.favorite ? "Отслеживаемый" : ""

                    self?.tableView.beginUpdates()

                    self?.billTypeLabel?.text = bill.lawType.description
                    self?.billTitle?.text = bill.name
                    self?.billCommentsLabel?.text = bill.comments

                    self?.introductionDateLabel?.text = bill.introductionDate.isoDateToReadableDate()
                    self?.introducedByLabel?.text = bill.generateSubjectsDescription()

                    self?.lastEventStageLabel?.text = bill.lastEventStage?.name
                    self?.lastEventPhaseLabel?.text = bill.lastEventPhase?.name
                    self?.lastEventDecisionLabel?.text = bill.generateSolutionDescription()
                    self?.lastEventDateLabel?.text = bill.generateLastEventDateDescription()
                    self?.lastEventDocumentLabel?.text = bill.generateLastEventDocumentDescription()

                    self?.respCommitteeLabel?.text = (bill.committeeResponsible?.name.count ?? 0 > 0) ? bill.committeeResponsible?.name : "Не указан"
                    self?.profileComitteesLabel?.text = bill.generateProfileCommitteesDescription()
                    self?.coexecCommitteeLabel?.text = bill.generateCoexecitorCommitteesDescription()

                    self?.tableView.endUpdates()
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

    @IBAction private func shareButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Скопировать описание", style: .default, handler: { [weak self] (action) in
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

        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))

        alert.popoverPresentationController?.barButtonItem = shareButton
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func organizedButtonPressed(_ sender: UIBarButtonItem) {
        organizeActionMenu()
    }

    @IBAction func organizedTextButtonPressed(_ sender: UIBarButtonItem) {
        organizeActionMenu()
    }

    private func organizeActionMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        guard let fav = bill?.favorite else {
            assertionFailure("Can't unwrap optional bill to add action in share menu")
            return
        }

        alert.addAction(UIAlertAction(title: fav ? "Убрать из отслеживаемых" : "Добавить в отслеживаемые", style: fav ? .destructive : .default, handler: { [weak self] _ in self?.changeFavoriteStatusAction()
        }))

        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.popoverPresentationController?.barButtonItem = organizedButton
        self.present(alert, animated: true, completion: nil)
    }

    func changeFavoriteStatusAction() {
        guard let realm = try? Realm(), let updBill = realm.object(ofType: Bill_.self, forPrimaryKey: self.bill?.number) else {
            assertionFailure("Can't instantiate realm or find the bill \(self.bill?.number ?? "number missing")")
            return
        }


        if let existingFavoriteBill = realm.object(ofType: FavoriteBill_.self, forPrimaryKey: updBill.number), existingFavoriteBill.markedToBeRemovedFromFavorites == false {

            if existingFavoriteBill.note.count > 0 {
                self.askToRemoveFavoriteBillWithNote {
                    try? realm.write {
                        existingFavoriteBill.markedToBeRemovedFromFavorites = true
                    }
                    try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: existingFavoriteBill.syncProxy)
                    self.organizedTextButton.title = ""
                }
            } else {
                try? realm.write {
                    existingFavoriteBill.markedToBeRemovedFromFavorites = true
                }
                try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: existingFavoriteBill.syncProxy)
                self.organizedTextButton.title = ""
            }

        } else {
            let newFavoriteBill = FavoriteBill_(fromBill: updBill)
            try? realm.write {
                realm.add(newFavoriteBill, update: true)
            }
            try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: newFavoriteBill.syncProxy)
            self.organizedTextButton.title = "Отслеживаемый"
        }
    }

    func askToRemoveFavoriteBillWithNote(completionIfTrue: @escaping ()->Void) {
        let alert = UIAlertController(title: "При удалении из отслеживаемых заметка также будет удалена", message: "Подтверждаете удаление из отслеживаемого?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) {
            (_) in completionIfTrue()
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
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
                [weak self] (_, totalCount) -> Void in
                // self?.bill = firstBill
                DispatchQueue.main.async {
                    self?.fetchExistingBillData()
                }
                
            })
        }
    }

}
