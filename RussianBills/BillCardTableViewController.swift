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

final class BillCardTableViewController: UITableViewController {
    let realm = try? Realm()
    
    @IBOutlet weak var billTypeLabel: UILabel!
    @IBOutlet weak var billTitle: UILabel!
    @IBOutlet weak var billSubtitleLabel: UILabel!
    @IBOutlet weak var introductionDateLabel: UILabel!
    @IBOutlet weak var introductedByLabel: UILabel!
    
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var decisionLabel: UILabel!
    
    @IBOutlet weak var respCommitteeLabel: UILabel!
    @IBOutlet weak var coexecCommitteeLabel: UILabel!
    @IBOutlet weak var profileComitteesLable: UILabel!
    
    @IBOutlet weak var goToAllEventsCell: UITableViewCell!

    @IBOutlet weak var moreDocsLabel: UILabel!
    @IBOutlet weak var moreDocsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var moreDocsCell: UITableViewCell!

    var billNr: String?

    lazy var bill: Bill_? = {
        return realm?.object(ofType: Bill_.self, forPrimaryKey: billNr)
    }()

    var parser: BillParser? {
        didSet {
            if let currentBill = bill, parser?.tree != nil {
                UserServices.setParserContent(ofBillNr: currentBill.number, to: parser!.tree)
            }
        }
    }

    var realmNotificationToken: NotificationToken? = nil

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        installRealmToken()
        tableView.delegate = self
        if bill?.favoriteHasUnseenChanges ?? false {
            try? realm?.write {
                bill?.favoriteHasUnseenChanges = false
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
            if currentBill.parserContent != nil  {
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


    // MARK: - Helper functions

    func fetchExistingBillData() {
        if let bill = bill {
            navigationItem.title = bill.favorite ? "🎖\(bill.number)" : "📃\(bill.number)"
            billTypeLabel.text = bill.lawType.description
            billTitle.text = bill.name
            billSubtitleLabel.text = bill.comments
            introductionDateLabel.text = bill.introductionDate
            introductedByLabel.text = bill.generateSubjectsDescription()
            stageLabel.text = bill.lastEventStage?.name
            phaseLabel.text = bill.lastEventPhase?.name
            decisionLabel.text = bill.generateFullSolutionDescription()
            respCommitteeLabel.text = bill.comitteeResponsible?.name
            profileComitteesLable.text = bill.generateProfileCommitteesDescription()
            coexecCommitteeLabel.text = bill.generateCoexecitorCommitteesDescription()
        } else {
            fatalError("Bill is not being provided")
        }
    }
    
    
    // MARK: - Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillDetailsSegue" {
            if let dest = segue.destination as? BillDetailsTableViewController, let content = bill?.parserContent {
                dest.parserContent = BillParserContent.deserialize(data: content)
                dest.billNumber = "\(bill!.number)"
                dest.bill = bill
            }
        }
    }

    
    // MARK: - AlertController

    @IBAction func composeButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Действия с законопроектом", message: "Выберите действие", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Сохранить как текстовый файл", style: .default, handler: { [weak self] (action) in
            FilesManager.createAndOrWriteToFileBillDescrition(text: (self?.description)!, name: (self?.bill!.number)!, atPath: NSHomeDirectory())
        }))

        alert.addAction(UIAlertAction(title: "Скопировать как текст", style: .default, handler: { (action) in
            UIPasteboard.general.string = self.description
        }))

        alert.addAction(UIAlertAction(title: (bill?.favorite)! ? "Убрать из избранного" : "Добавить в избранное" , style: .default, handler: { [weak self] (action) in

            let realm = try? Realm()
            if let updBill = realm?.object(ofType: Bill_.self, forPrimaryKey: self?.bill?.number)  {
                try? realm?.write {
                    updBill.favorite = !updBill.favorite
                    updBill.favoriteUpdatedTimestamp = Date()
                }
            }

            self?.navigationItem.title = (self?.bill?.favorite)! ? "🎖\(self?.bill!.number ?? "")" : "📃\(self?.bill!.number ?? "")"
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Helper functions

    func installRealmToken() {
        guard let currentBill = bill else {
            return
        }

        realmNotificationToken = currentBill.observe { [weak self] (_)->Void in
            if currentBill.parserContent != nil {
                self?.activateMoreInfoCell()
            }
        }
    }

    func activateMoreInfoCell() {
        moreDocsLabel.text = "Все события и документы"
        moreDocsLabel.textColor = moreDocsLabel.tintColor
        moreDocsIndicator.stopAnimating()
        moreDocsCell.accessoryType = .disclosureIndicator
        moreDocsCell.isUserInteractionEnabled = true
    }

    func beginStagesParsing() {
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

    func reloadCurrentBillData() {
        if let billNumber = bill?.number {
            let searchQuery = BillSearchQuery(withNumber: billNumber)
            UserServices.downloadBills(withQuery: searchQuery, completion: { (bills)->Void in
                if bills.count > 0 {
                    self.bill = bills.first!
                    self.fetchExistingBillData()
                }
            })
        }
    }

}
