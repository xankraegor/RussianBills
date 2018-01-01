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

    var receivedDeputyId = -1
    var receivedCouncilId = -1
    var receivedFederalSubjectId = -1
    var receivedRegionalSubjectId = -1

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

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        form

            +++ Section("Основные данные")
            // MARK: Law Type
            <<< PushRow<String>() {
                $0.title = "Тип"
                $0.selectorTitle = "Выберите тип законопроекта"
                $0.options = ["Любой", LawType.federalLaw.description, LawType.federalConstitutionalLaw.description, LawType.constitutionalAmendment.description]
                $0.value = "Любой"    // initially selected
                }.onChange { [weak self] row in
                    self?.setLawType(withStatus: row.value ?? "")
            }
            // MARK: Name
            <<< TextAreaRow() { row in
                row.placeholder = "Наименование законопроекта: целиком или частично"
                }.onChange { [weak self] row in
                    self?.query.name = row.value
            }
            // MARK: Number
            <<< TextRow() { row in
                row.title = "Номер и созыв"
                row.placeholder = "в формате 1234567-8"
                }.onChange { [weak self] row in
                    self?.query.number = row.value
            }
            +++ Section("Статус")
            // MARK: Status
            <<< PushRow<String>("Статус") {
                $0.title = ""
                $0.selectorTitle = "Выберите статус законопроекта"
                var allValues = (BillStatus.allValues.map {$0.description})
                allValues.append("Любой")
                $0.options = allValues
                $0.value = "Любой"    // initially selected
                }.onChange { [weak self] row in
                    self?.setBillStatus(to: row.value ?? "")
            }

            +++ Section("Период внесения законопроекта")
            // MARK: Begin intro date switch
            <<< SwitchRow("beginDateSwitch") {
                $0.title = "Дата начала"
                $0.cell.switchControl.tintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.cell.switchControl.onTintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.value = false
                }.onChange{ [weak self] (row) in
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
                }
            // MARK: Begin intro date
            <<< DateRow("beginDate") {
                $0.hidden = Condition.function(["beginDateSwitch"], { form in
                    return !((form.rowBy(tag: "beginDateSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.title = ""
                $0.value = Date()
                }.onChange{ [weak self] row in
                    if let existingDate = row.value {
                        self?.query.registrationStart = Date.ISOStringFromDate(date: existingDate)
                    }
                }
            // MARK: End intro date switch
            <<< SwitchRow("endDateSwitch") {
                $0.title = "Дата окончания"
                $0.cell.switchControl.tintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.cell.switchControl.onTintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.value = false
                }.onChange{ [weak self] (row) in
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
                }
            // MARK: End intro date
            <<< DateRow("endDate") {
                $0.hidden = Condition.function(["endDateSwitch"], { form in
                    return !((form.rowBy(tag: "endDateSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.title = ""
                $0.value = Date()
                }.onChange{ [weak self] row in
                    if let existingDate = row.value {
                        self?.query.registrationEnd = Date.ISOStringFromDate(date: existingDate)
                    }
                }

            +++ Section("Субъекты закинициативы")
            // MARK: Duma Deputy switch
            <<< SwitchRow("deputySwitch") {
                $0.title = "Депутат Госдумы"
                $0.value = receivedDeputyId > 0 ? true : false
                $0.cell.switchControl.tintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.cell.switchControl.onTintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                }.onChange{ [weak self] (row) in
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
                }
            // MARK: Duma Deputy
            <<< SearchPushRow<Deputy_>("deputyPerson") {
                $0.selectorTitle = "Выберите депутата"
                var deps = deputies
                let absentValue = Deputy_(withFakeName: "Любой")
                deps.insert(absentValue, at: 0)
                $0.options = deps
                // initially selected value
                if receivedDeputyId > 0, let realm = try? Realm(), let deputy = realm.object(ofType: Deputy_.self, forPrimaryKey: receivedDeputyId) {
                    $0.value = deputy
                    self.query.deputyId = receivedDeputyId
                } else {
                    $0.value = absentValue
                }

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
            // MARK: Council Member switch
            <<< SwitchRow("councilSwitch") {
                $0.title = "Член Совета Федерации"
                $0.value = receivedCouncilId > 0 ? true : false
                $0.cell.switchControl.tintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.cell.switchControl.onTintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                }.onChange{ [weak self] (row) in
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
                }
            // MARK: Council member
            <<< SearchPushRow<Deputy_>("councilPerson") {
                $0.selectorTitle = "Выберите члена Совета Федерации"
                var deps = councilMembers
                let absentValue = Deputy_(withFakeName: "Любой")
                deps.insert(absentValue, at: 0)
                $0.options = deps

                // initially selected value
                if receivedCouncilId > 0, let realm = try? Realm(), let member = realm.object(ofType: Deputy_.self, forPrimaryKey: receivedCouncilId) {
                    $0.value = member
                    self.query.deputyId = receivedCouncilId
                } else {
                    $0.value = absentValue
                }

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

            // MARK: Federal Subject switch
            <<< SwitchRow("federalSwitch") {
                $0.title = "Федеральный орган госвласти"
                $0.cell.switchControl.tintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.cell.switchControl.onTintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.value = receivedFederalSubjectId > 0 ? true : false
                }.onChange{ [weak self] (row) in
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
                }
            // MARK: Federal Subject
            <<< SearchPushRow<FederalSubject_>("federalBody") {
                $0.selectorTitle = "Выберите федеральный орган власти"
                var feds = federalSubjects
                let absentValue = FederalSubject_(__withFakeName: "Любой")
                feds.insert(absentValue, at: 0)
                $0.options = feds
                // initially selected value
                if receivedFederalSubjectId > 0, let realm = try? Realm(), let fedsub = realm.object(ofType: FederalSubject_.self, forPrimaryKey: receivedFederalSubjectId) {
                    $0.value = fedsub
                    self.query.federalSubjectId = receivedFederalSubjectId
                } else {
                    $0.value = absentValue
                }


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

            // MARK: Regional Subject switch
            <<< SwitchRow("regionalSwitch") {
                $0.title = "Региональный орган зак. власти"
                $0.value = receivedRegionalSubjectId > 0 ? true : false
                $0.cell.switchControl.tintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                $0.cell.switchControl.onTintColor = #colorLiteral(red: 0.1269444525, green: 0.5461069942, blue: 0.8416815996, alpha: 1)
                }.onChange{ [weak self] (row) in
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
                }
            // MARK: Regional Subject
            <<< SearchPushRow<RegionalSubject_>("regionalBody") {
                $0.selectorTitle = "Выберите региональный орган власти"
                var regs = regionalSubjects
                let absentValue = RegionalSubject_(__withFakeName: "Любой")
                regs.insert(absentValue, at: 0)
                $0.options = regs

                // initially selected value
                if receivedRegionalSubjectId > 0, let realm = try? Realm(), let regsub = realm.object(ofType: RegionalSubject_.self, forPrimaryKey: receivedRegionalSubjectId) {
                    $0.value = regsub
                    self.query.regionalSubjectId = receivedRegionalSubjectId
                } else {
                    $0.value = absentValue
                }

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

            +++ Section("Сортировать по:")
            // MARK: Sort order
            <<< PushRow<String>("sortOrder") {
                $0.title = ""
                $0.selectorTitle = "Сортировать по:"
                $0.cell.detailTextLabel?.textColor = UIColor.black
                $0.options = BillSearchQuerySortType.allValues.map {$0.description}
                $0.value = BillSearchQuerySortType.last_event_date.description  // initially selected
                }.onChange { [weak self] row in
                    self?.setSortOrder(to: row.value ?? "")
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        super.viewWillAppear(animated)
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
            guard let existingQuery = self?.query else {
                assertionFailure("∆ preprocessRequest: existingQuery missing")
                return
            }
            UserServices.downloadBills(withQuery: existingQuery) { (resultBills, totalCount) in
                let realm = try? Realm()
                let newList = BillsList_(withName: BillsListType.mainSearch, totalCount: totalCount)
                newList.bills.append(objectsIn: resultBills)
                try? realm?.write { realm?.add(newList, update: true) }
                self?.prefetchedBills = true
            }
        }
    }
}
