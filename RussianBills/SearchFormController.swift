//
//  SearchFormController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

final class SearchFormController: FormViewController {
    
    var query = BillSearchQuery() {
        didSet {
            preprocessRequest(usingQuery: query, afterSeconds: 1.0)
        }
    }

    var prefetchedBills = false

    lazy var deputies: [Deputy_] = {
        if let members = try? Realm().objects(Deputy_.self).filter("position CONTAINS[cd] 'депутат'").sorted(byKeyPath: "name", ascending: true) {
            return Array(members)
        } else {
            return []
        }
    }()

    lazy var councilMembers: [Deputy_] = {
        if let members = try? Realm().objects(Deputy_.self).filter("position CONTAINS[cd] 'член'").sorted(byKeyPath: "name", ascending: true) {
            return Array(members)
        } else {
            return []
        }
    }()

    lazy var federalSubjects: [FederalSubject_] = {
        if let members = try? Realm().objects(FederalSubject_.self).sorted(byKeyPath: "id", ascending: true) {
            return Array(members)
        } else {
            return []
        }
    }()

    lazy var regionalSubjects: [RegionalSubject_] = {
        if let members = try? Realm().objects(RegionalSubject_.self).sorted(byKeyPath: "name", ascending: true) {
            return Array(members)
        } else {
            return []
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form
            
            +++ Section("Основные данные")
            <<< PushRow<String>() {
                $0.title = "Тип"
                $0.selectorTitle = "Выберите тип законопроекта"
                $0.options = ["Любой", LawType.federalLaw.description, LawType.federalConstitutionalLaw.description, LawType.constitutionalAmendment.description]
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
                            assertionFailure("∆ Something went wrong with accessing begin date from the search form")
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
                            assertionFailure("∆ Something went wrong with accessing end date from the search form")
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

            +++ Section("Субъекты закинициативы")

            // MARK: Duma Deputy

            <<< SwitchRow("deputySwitch"){
                $0.title = "Депутат Госдумы РФ"
                $0.value = false
                }.onChange({ [weak self] (row) in
                    let switchValue = row.value ?? false
                    if switchValue {
                        let councilSwitch = self?.form.rowBy(tag: "councilSwitch")
                        (councilSwitch as! SwitchRow).value = false
                        councilSwitch?.updateCell()
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let deputy = dict["deputyPerson"] as? Deputy_ {
                            self?.query.deputyId = deputy.id
                        } else {
                            assertionFailure("∆ Something went wrong with accessing deputy from the search form")
                        }
                    } else {
                        // Nullify the date
                        self?.query.deputyId = nil
                    }
                })

            <<< PushRow<Deputy_>("deputyPerson") {
                $0.selectorTitle = "Выберите депутата"
                var deps = deputies
                let absentValue = Deputy_(__withFakeName: "Любой")
                deps.insert(absentValue, at: 0)
                $0.options = deps
                $0.value = absentValue // initially selected
                $0.hidden = Condition.function(["deputySwitch"], { form in
                    return !((form.rowBy(tag: "deputySwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let deputyName = $0?.name, deputyName != "Любой", let deputyCurrent = $0?.isCurrent {
                        return "\(deputyCurrent ? "✅" : "⏹") \(deputyName) "
                    }
                    return "Любой"
                }
                $0.cell.textLabel?.numberOfLines = 0
                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id, let deputy = try? Realm().object(ofType: Deputy_.self, forPrimaryKey: id), let existingDeputy = deputy {
                        self?.query.deputyId = existingDeputy.id
                    }
            }

            // MARK: Council Member

            <<< SwitchRow("councilSwitch"){
                $0.title = "Член Совета Федерации"
                $0.value = false
                }.onChange({ [weak self] (row) in
                    let switchValue = row.value ?? false
                    if switchValue {
                        let deputySwitch = self?.form.rowBy(tag: "deputySwitch")
                        (deputySwitch as! SwitchRow).value = false
                        deputySwitch?.updateCell()
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let deputy = dict["councilPerson"] as? Deputy_ {
                            self?.query.deputyId = deputy.id
                        } else {
                            assertionFailure("∆ Something went wrong with accessing council member from the search form")
                        }
                    } else {
                        // Nullify the date
                        self?.query.deputyId = nil
                    }
                })

            <<< PushRow<Deputy_>("councilPerson") {
                $0.selectorTitle = "Выберите члена Совета Федерации"
                var deps = councilMembers
                let absentValue = Deputy_(__withFakeName: "Любой")
                deps.insert(absentValue, at: 0)
                $0.options = deps
                $0.value = absentValue // initially selected
                $0.hidden = Condition.function(["councilSwitch"], { form in
                    return !((form.rowBy(tag: "councilSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let deputyName = $0?.name, deputyName != "Любой", let deputyCurrent = $0?.isCurrent {
                        return "\(deputyCurrent ? "✅" : "⏹") \(deputyName) "
                    }
                    return "Любой"
                }
                $0.cell.textLabel?.numberOfLines = 0
                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id, let deputy = try? Realm().object(ofType: Deputy_.self, forPrimaryKey: id), let existingDeputy = deputy {
                        self?.query.deputyId = existingDeputy.id
                    }
            }

            // MARK: Federal Subject

            <<< SwitchRow("federalSwitch"){
                $0.title = "Федеральный орган госвласти"
                $0.value = false
                }.onChange({ [weak self] (row) in
                    let switchValue = row.value ?? false
                    if switchValue {
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let fed = dict["federalBody"] as? FederalSubject_ {
                            self?.query.federalSubjectId = fed.id
                        } else {
                            assertionFailure("∆ Something went wrong with accessing deputy from the search form")
                        }
                    } else {
                        // Nullify the date
                        self?.query.federalSubjectId = nil
                    }
                })

            <<< PushRow<FederalSubject_>("federalBody") {
                $0.selectorTitle = "Выберите федеральный орган власти"
                var feds = federalSubjects
                let absentValue = FederalSubject_(__withFakeName: "Любой")
                feds.insert(absentValue, at: 0)
                $0.options = feds
                $0.value = absentValue // initially selected
                $0.hidden = Condition.function(["federalSwitch"], { form in
                    return !((form.rowBy(tag: "federalSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let name = $0?.name, name != "Любой", let current = $0?.isCurrent {
                        return "\(current ? "✅" : "⏹") \(name) "
                    }
                    return "Любой"
                }
                $0.cell.textLabel?.numberOfLines = 0
                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id, let deputy = try? Realm().object(ofType: Deputy_.self, forPrimaryKey: id), let existingDeputy = deputy {
                        self?.query.deputyId = existingDeputy.id
                    }

            }

            // MARK: Regional Subject

            <<< SwitchRow("regionalSwitch"){
                $0.title = "Региональный орган зак. власти"
                $0.value = false
                }.onChange({ [weak self] (row) in
                    let switchValue = row.value ?? false
                    if switchValue {
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let reg = dict["regionalBody"] as? RegionalSubject_ {
                            self?.query.regionalSubjectId = reg.id
                        } else {
                            assertionFailure("∆ Something went wrong with accessing regional subject from the search form")
                        }
                    } else {
                        // Nullify the date
                        self?.query.regionalSubjectId = nil
                    }
                })

            <<< PushRow<RegionalSubject_>("regionalBody") {
                $0.selectorTitle = "Выберите региональный орган власти"
                var regs = regionalSubjects
                let absentValue = RegionalSubject_(__withFakeName: "Любой")
                regs.insert(absentValue, at: 0)
                $0.options = regs
                $0.value = absentValue // initially selected
                $0.hidden = Condition.function(["regionalSwitch"], { form in
                    return !((form.rowBy(tag: "regionalSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let name = $0?.name, name != "Любой", let current = $0?.isCurrent {
                        return "\(current ? "✅" : "⏹") \(name) "
                    }
                    return "Любой"
                }
                $0.cell.textLabel?.numberOfLines = 0
                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id, let deputy = try? Realm().object(ofType: Deputy_.self, forPrimaryKey: id), let existingDeputy = deputy {
                        self?.query.deputyId = existingDeputy.id
                    }
        }

        +++ Section("Порядок сортировки")
        <<< PushRow<String>("sortOrder") {
                $0.title = ""
                $0.selectorTitle = "Выберите порядок сортировки"
                $0.options = BillSearchQuerySortType.allValues.map{$0.description}
                $0.value = BillSearchQuerySortType.last_event_date.description  // initially selected
                }.onChange { [weak self] row in
                    self?.setSortOrder(to: row.value ?? "")
            }

    }

    // MARK: - Updating Query
    
    func setLawType(withStatus type: String) {
        switch type {
        case LawType.federalLaw.description:
            query.lawType = LawType.federalLaw
        case LawType.federalConstitutionalLaw.description:
            query.lawType = LawType.federalConstitutionalLaw
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

    func setSortOrder(to order: String) {

        switch order {
        case BillSearchQuerySortType.name.description:
            query.sortType = .name
        case BillSearchQuerySortType.number.description:
            query.sortType = .number
        case BillSearchQuerySortType.date.description:
            query.sortType = .date
        case BillSearchQuerySortType.date_asc.description:
            query.sortType = .date_asc
        // case BillSearchQuerySortType.last_event_date.description
        case BillSearchQuerySortType.last_event_date_asc.description:
            query.sortType = .last_event_date_asc
        case BillSearchQuerySortType.responsible_committee.description:
            query.sortType = .responsible_committee
        default:
            //case last_event_date:
            query.sortType = .last_event_date
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegueId" {
            (segue.destination as? SearchResultsTableViewController)?.query = query
            (segue.destination as? SearchResultsTableViewController)?.isPrefetched = prefetchedBills
        }
    }

    // MARK: - Request Preprocessing

    func preprocessRequest(usingQuery: BillSearchQuery, afterSeconds: Double) {
        Dispatcher.shared.dispatchBillsPrefetching(afterSeconds: afterSeconds) { [weak self] in
            if let existingQuery = self?.query {
                UserServices.downloadBills(withQuery: existingQuery) { (resultBills, totalCount) in
                    let realm = try? Realm()
                    let newList = BillsList_(withName: BillsListType.mainSearch, totalCount: totalCount)
                    newList.bills.append(objectsIn: resultBills)
                    try? realm?.write {realm?.add(newList, update: true)}
                    self?.prefetchedBills = true
                }
            } else {
                assertionFailure("∆ preprocessRequest: existingQuery missing")
            }
        }
    }
}
