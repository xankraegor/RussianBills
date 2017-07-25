//
//  BillCardTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Kanna

final class BillCardTableViewController: UITableViewController {
    
    var bill: Bill_?

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

    var parser: BillParser? {
        didSet {
            if parser != nil {
                goToAllEventsCell.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        fetchBillData()

        if let billUrlString = bill?.url,
            let billUrl = URL(string: billUrlString) {
            Request.htmlToParse(forUrl: billUrl, completion: { (html) in
                DispatchQueue.main.sync {
                    self.parser = BillParser(withHTML: html)
                }
            })
        }
        
        if let billNumber = bill?.number {
            let searchQuery = BillSearchQuery(withNumber: billNumber)
            UserServices.downloadBills(withQuery: searchQuery, markFavorite: true, completion: { (bills)->Void in
                if bills.count > 0 {
                    self.bill = bills.first!
                    self.fetchBillData()
                }
            })
        
        }
        
    }
    
    // MARK: - Table view delegate
//
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 0 && ( 4...6 ~= indexPath.row ) { // Flag colors
//            print("(\(indexPath.section)\(indexPath.row)) height = 8")
//            return 8
//        } else {
//            print("(\(indexPath.section)\(indexPath.row)) height = \(UITableViewAutomaticDimension)")
//            return UITableViewAutomaticDimension
//        }
//    }
    

    // MARK: - Helper functions

    func fetchBillData() {
        if let bill = bill {
            navigationItem.title = "📃\(bill.number)"
            billTypeLabel.text = bill.lawType.description
            billTitle.text = bill.name
            billSubtitleLabel.text = bill.comments
            introductionDateLabel.text = bill.introductionDate
            introductedByLabel.text = bill.generateSubjectsDescription()
            stageLabel.text = bill.lastEventStage?.name
            phaseLabel.text = bill.lastEventPhase?.name
            decisionLabel.text = bill.generateFullSolutionDescription()
        } else {
            fatalError("Bill is not being provided")
        }
    }
    
    // MARK: - Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillDetailsSegue" {
            if let dest = segue.destination as? BillDetailsTableViewController, let tree = parser?.tree {
                dest.tree = tree
                dest.billNumber = "\(bill!.number)"
            }
        }
    }

    // MARK: - AlertController

    @IBAction func ComposeButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Сохранить данные о законопроекте", message: "Выберите действие", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Сохранить как текстовый файл", style: .default, handler: { (action) in
            self.saveBillEventsToAFile()
        }))

        alert.addAction(UIAlertAction(title: "Скопировать как текст", style: .default, handler: { (action) in
            UIPasteboard.general.string = self.generateBillDescriptionText()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Helper functions

    private func generateBillDescriptionText()->String {
        let repl = "отсутствует"
        var output = ""
        if let bill = bill {
            output += "Проект нормативно-правового акта №" + replace(WithText: repl, ifMissingSourceText: bill.number) + "\n"
            output += "Тип нормативно-правового акта: " + replace(WithText: repl, ifMissingSourceText: bill.lawType.description) + "\n"
            output += "Наименование проекта нормативно-правового акта: " + replace(WithText: repl, ifMissingSourceText: bill.name) + "\n"
            output += "Описание проекта нормативно-правового акта: " + replace(WithText: repl, ifMissingSourceText: bill.comments) + "\n"
            output += "Внёсен: " + replace(WithText: repl, ifMissingSourceText: bill.introductionDate) + "\n"
            output += "Субъекты законодательной инициативы: " + replace(WithText: repl, ifMissingSourceText: bill.generateSubjectsDescription() ?? "") + "\n"
            if let parser = parser {
                output += "СОБЫТИЯ РАССМОТРЕНИЯ ПРОЕКТА НОРМАТИВНО-ПРАВОВОГО АКТА\n"
                for phase in parser.tree {
                    output += String(repeating: " ", count: 5)
                    for event in phase.events {
                        output += "\n"
                        output += String(repeating: " ", count: 10) + replace(WithText: "Название события не указано", ifMissingSourceText: event.name ) + "\n"
                        output += String(repeating: " ", count: 10) + replace(WithText: "Дата события не указана", ifMissingSourceText: event.date ?? "") + "\n"
                        output += String(repeating: " ", count: 10) + "Прикреплено документов: " + String(event.attachments.count) + "\n"
                    }
                }
            } else {
                output += "Текущая стадия рассмотрения: " + replace(WithText: repl, ifMissingSourceText: bill.lastEventStage?.name ?? "") + "\n"
                output += "Текущая фаза рассмотрения: " + replace(WithText: repl, ifMissingSourceText: bill.lastEventPhase?.name ?? "") + "\n"
                output += "Принятое решение: " + replace(WithText: repl, ifMissingSourceText: bill.generateFullSolutionDescription()) + "\n"
            }
        }

        return output
    }

    private func replace(WithText replacementText: String, ifMissingSourceText source: String)->String {
        let textWithoutSpaces = source.trimmingCharacters(in: .whitespacesAndNewlines)
        return textWithoutSpaces.characters.count > 0 ? source : replacementText
    }

    private func saveBillEventsToAFile() {
        if let bill = self.bill {
            let text = self.generateBillDescriptionText()
            FilesManager.createAndOrWriteToFile(text: text, name: "\(bill.name).txt", path: "/")
        }
    }
    

}
