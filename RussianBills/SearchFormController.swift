//
//  SearchFormController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Eureka

final class SearchFormController: FormViewController {
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    var query = BillSearchQuery() {
        didSet {
            startButton.isEnabled = query.hasAnyFilledFields()
            preprocessRequest(usingQuery: query, afterSeconds: 0.5)
        }
    }

    var hasPrefetchedBills = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form
            
            +++ Section("Основные данные")
            <<< PushRow<String>() {
                $0.title = "Тип"
                $0.selectorTitle = "Выберите тип законопроекта"
                $0.options = ["Любой", LawType.federalLaw.description, LawType.federalConstitionalLaw.description, LawType.constitutionalAmendment.description]
                $0.value = "Любой"    // initially selected
                }.onChange { [weak self] row in
                    self?.setLawType(withStatus: row.value ?? "")
            }
            <<< TextAreaRow(){ row in
                row.placeholder = "Наименование законопроекта: целиком или частично"
                }.onChange { [weak self] row in
                    self?.query.name = row.value
            }
            <<< TextRow(){ row in
                row.title = "Номер и созыв"
                row.placeholder = "в формате 1234567-8"
                }.onChange { [weak self] row in
                    self?.query.number = row.value
            }
            +++ Section("Статус")
            <<< PushRow<String>("Статус") {
                $0.title = ""
                $0.selectorTitle = "Выберите статус законопроекта"
                var allValues = (BillStatus.allValues.map{$0.description})
                allValues.append("Любой")
                $0.options = allValues
                $0.value = "Любой"    // initially selected
                }.onChange { [weak self] row in
                    self?.setBillStatus(to: row.value ?? "")
            }

            +++ Section("Дата внесения законопроекта")
            <<< SwitchRow("beginDateSwitch"){
                $0.title = "Начиная с даты"
                $0.value = false
                }.onChange({ [weak self] (row) in
                    let switchValue = row.value ?? false
                    if switchValue {
                        // Set value from begin date to query
                        let dateRow: DateRow? = self?.form.rowBy(tag: "beginDate")
                        if let existingDate = dateRow?.value {
                            self?.query.registrationStart = Date.ISOStringFromDate(date: existingDate)
                            } else {
                            debugPrint("∆ Something went wrong with accessing begin date from the search form")
                        }
                    } else {
                        // Nullify the date
                        self?.query.registrationStart = nil
                    }
                })
            <<< DateRow("beginDate"){
                $0.hidden = Condition.function(["beginDateSwitch"], { form in
                    return !((form.rowBy(tag: "beginDateSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.title = ""
                $0.value = Date()
                }.onChange({ [weak self] row in
                    if let existingDate = row.value {
                        self?.query.registrationStart = Date.ISOStringFromDate(date: existingDate)
                    }
                })
            <<< SwitchRow("endDateSwitch"){
                $0.title = "Заканчивая датой"
                $0.value = false
                }.onChange({ [weak self] (row) in
                    let switchValue = row.value ?? false
                    if switchValue {
                        // Set value from end date to query
                        let dateRow: DateRow? = self?.form.rowBy(tag: "endDate")
                        if let existingDate = dateRow?.value {
                            self?.query.registrationEnd = Date.ISOStringFromDate(date: existingDate)
                        } else {
                            debugPrint("∆ Something went wrong with accessing end date from the search form")
                        }
                    } else {
                        // Nullify the date
                        self?.query.registrationStart = nil
                    }
                })
            <<< DateRow("endDate"){
                $0.hidden = Condition.function(["endDateSwitch"], { form in
                    return !((form.rowBy(tag: "endDateSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.title = ""
                $0.value = Date()
                }.onChange({ [weak self] row in
                    if let existingDate = row.value {
                        self?.query.registrationEnd = Date.ISOStringFromDate(date: existingDate)
                    }
                })
    }

    // MARK: - Updating Query
    
    func setLawType(withStatus type: String) {
        switch type {
        case LawType.federalLaw.description:
            query.lawType = LawType.federalLaw
        case LawType.federalConstitionalLaw.description:
            query.lawType = LawType.federalConstitionalLaw
        case LawType.constitutionalAmendment.description:
            query.lawType = LawType.constitutionalAmendment
        default: // "Любой"
            query.lawType = nil
        }
    }

    func setBillStatus(to status: String) {
        switch status {
        case BillStatus.examination.description:
            query.status = BillStatus.examination
        case BillStatus.extraprogrammaticalSubmitted.description:
            query.status = BillStatus.extraprogrammaticalSubmitted
        case BillStatus.finished.description:
            query.status = BillStatus.finished
        case BillStatus.finishedByOtherReasons.description:
            query.status = BillStatus.finishedByOtherReasons
        case BillStatus.inCommitteeProgramme.description:
            query.status = BillStatus.inCommitteeProgramme
        case BillStatus.inProgramme.description:
            query.status = BillStatus.inProgramme
        case BillStatus.recalled.description:
            query.status = BillStatus.recalled
        case BillStatus.rejected.description:
            query.status = BillStatus.rejected
        case BillStatus.signed.description:
            query.status = BillStatus.signed
        case BillStatus.submitted.description:
            query.status = BillStatus.submitted
        default:
            query.status = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startButton.isEnabled = query.hasAnyFilledFields()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegueId" {
            (segue.destination as? SearchResultsTableViewController)?.query = query
            (segue.destination as? SearchResultsTableViewController)?.isPrefetched = hasPrefetchedBills
        }
    }

    // MARK: - Request Preprocessing

    func preprocessRequest(usingQuery: BillSearchQuery, afterSeconds: Double) {
        Dispatcher.shared.dispatchBillsPrefetching(afterSeconds: afterSeconds) { [weak self] in
            if let existingQuery = self?.query {
                UserServices.downloadAndSaveBills(withQuery: existingQuery)
                { [weak self] (bills) in
                    RealmCoordinator.setBillsList(ofType: .mainSearchList, toContain: bills)
                    self?.hasPrefetchedBills = true
                }
            } else {
                debugPrint("∆ preprocessRequest: existingQuery missing")
            }
        }
    }
}
