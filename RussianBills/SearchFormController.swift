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

    var previousQuery = BillSearchQuery(withNumber: "0")

    var query = BillSearchQuery() {
        didSet {
            if query != previousQuery {
                previousQuery = query
                preprocessRequest(usingQuery: query, afterSeconds: 1.0)
            }
        }
    }

    let anyoneName = "Любой"

    var billsAlreadyFetched = false

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
                $0.options = [anyoneName, LawType.federalLaw.description, LawType.federalConstitutionalLaw.description, LawType.constitutionalAmendment.description]
                $0.value = anyoneName    // initially selected
                }.onChange { [weak self] row in
                    self?.query.setLawType(withDescription: row.value ?? "")
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
                var allValues = (BillStatus.allValues.map {
                    $0.description
                })
                allValues.append(anyoneName)
                $0.options = allValues
                $0.value = anyoneName    // initially selected
                }.onChange { [weak self] row in
                    self?.query.setBillStatus(withDescription: row.value ?? "")
            }

            +++ Section("Период внесения законопроекта")
            // MARK: Begin intro date switch
            <<< SwitchRow("beginDateSwitch") {
                $0.title = "Дата начала"
                $0.cell.switchControl.tintColor = UIColor.ztint
                $0.cell.switchControl.onTintColor = UIColor.ztint
                $0.value = false
                }.onChange { [weak self] (row) in

                    if row.value ?? false {
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
                }.onChange { [weak self] row in
                    if let existingDate = row.value {
                        self?.query.registrationStart = Date.ISOStringFromDate(date: existingDate)
                    }
            }
            // MARK: End intro date switch
            <<< SwitchRow("endDateSwitch") {
                $0.title = "Дата окончания"
                $0.cell.switchControl.tintColor = UIColor.ztint
                $0.cell.switchControl.onTintColor = UIColor.ztint
                $0.value = false
                }.onChange { [weak self] (row) in

                    if row.value ?? false {
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
                }.onChange { [weak self] row in
                    if let existingDate = row.value {
                        self?.query.registrationEnd = Date.ISOStringFromDate(date: existingDate)
                    }
            }

            +++ Section("Субъекты закинициативы")
            // MARK: Duma Deputy switch
            <<< SwitchRow("deputySwitch") {
                $0.title = "Депутат Госдумы"
                $0.value = receivedDeputyId > 0 ? true : false
                $0.cell.switchControl.tintColor = UIColor.ztint
                $0.cell.switchControl.onTintColor = UIColor.ztint
                }.onChange { [weak self] (row) in

                    if row.value ?? false {
                        let councilSwitch = self?.form.rowBy(tag: "councilSwitch")
                        (councilSwitch as! SwitchRow).value = false
                        councilSwitch?.updateCell()
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let deputy = dict["deputyPerson"] as? Deputy_ {
                            self?.query.deputyId = deputy.id > 0 ? deputy.id : nil
                        } else {
                            assertionFailure("∆ Something went wrong with accessing deputy from the search form")
                        }
                    } else {
                        // Nullify deputy
                        self?.query.deputyId = nil
                    }
            }
            // MARK: Duma Deputy
            <<< SearchPushRow<Deputy_>("deputyPerson") {
                $0.selectorTitle = "Выберите депутата"
                var deps = deputies
                let absentValue = Deputy_(withFakeName: anyoneName)
                deps.insert(absentValue, at: 0)
                $0.options = deps
                // Value selected from a reference category page
                if receivedDeputyId > 0, let realm = try? Realm(), let deputy = realm.object(ofType: Deputy_.self, forPrimaryKey: receivedDeputyId) {
                    $0.value = deputy
                    self.query.deputyId = receivedDeputyId
                } else {
                    $0.value = absentValue
                    self.query.deputyId = nil
                }

                $0.hidden = Condition.function(["deputySwitch"], { form in
                    return !((form.rowBy(tag: "deputySwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let deputyName = $0?.name, deputyName != self.anyoneName, let deputyCurrent = $0?.isCurrent {
                        return "\(deputyCurrent ? "[Дейс.]" : "[Бывш.]") \(deputyName) "
                    }
                    return self.anyoneName
                }

                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id,
                        let deputy = try? Realm().object(ofType: Deputy_.self, forPrimaryKey: id),
                        let existingDeputy = deputy {
                        self?.query.deputyId = existingDeputy.id
                    }
            }
            // MARK: Council Member switch
            <<< SwitchRow("councilSwitch") {
                $0.title = "Член Совета Федерации"
                $0.value = receivedCouncilId > 0 ? true : false
                $0.cell.switchControl.tintColor = UIColor.ztint
                $0.cell.switchControl.onTintColor = UIColor.ztint
                }.onChange { [weak self] (row) in

                    if row.value ?? false {
                        let deputySwitch = self?.form.rowBy(tag: "deputySwitch")
                        (deputySwitch as! SwitchRow).value = false
                        deputySwitch?.updateCell()
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let deputy = dict["councilPerson"] as? Deputy_ {
                            self?.query.deputyId = deputy.id > 0 ? deputy.id : nil
                        } else {
                            assertionFailure("∆ Something went wrong with accessing council member from the search form")
                        }
                    } else {
                        // Nullify deputy
                        self?.query.deputyId = nil
                    }
            }
            // MARK: Council member
            <<< SearchPushRow<Deputy_>("councilPerson") {
                $0.selectorTitle = "Выберите члена Совета Федерации"
                var deps = councilMembers
                let absentValue = Deputy_(withFakeName: anyoneName)
                deps.insert(absentValue, at: 0)
                $0.options = deps

                // Value selected from a reference category page
                if receivedCouncilId > 0,
                    let realm = try? Realm(),
                    let member = realm.object(ofType: Deputy_.self, forPrimaryKey: receivedCouncilId) {
                    $0.value = member
                    self.query.deputyId = receivedCouncilId
                } else {
                    $0.value = absentValue
                    self.query.deputyId = nil
                }

                $0.hidden = Condition.function(["councilSwitch"], { form in
                    return !((form.rowBy(tag: "councilSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let deputyName = $0?.name, deputyName != self.anyoneName, let deputyCurrent = $0?.isCurrent {
                        return "\(deputyCurrent ? "[Дейс.]" : "[Бывш.]") \(deputyName) "
                    }
                    return self.anyoneName
                }

                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id,
                        let deputy = try? Realm().object(ofType: Deputy_.self, forPrimaryKey: id),
                        let existingDeputy = deputy {
                        self?.query.deputyId = existingDeputy.id
                    }
            }

            // MARK: Federal Subject switch
            <<< SwitchRow("federalSwitch") {
                $0.title = "Федеральный орган госвласти"
                $0.cell.switchControl.tintColor = UIColor.ztint
                $0.cell.switchControl.onTintColor = UIColor.ztint
                $0.value = receivedFederalSubjectId > 0 ? true : false
                }.onChange { [weak self] (row) in

                    if row.value ?? false {
                        // Set value from end date to query
                        if let dict = self?.form.values(includeHidden: true),
                            let fed = dict["federalBody"] as? FederalSubject_ {
                            self?.query.federalSubjectId = fed.id > 0 ? fed.id : nil

                        } else {
                            assertionFailure("∆ Something went wrong with accessing deputy from the search form")
                        }
                    } else {
                        // Nullify federal subject
                        self?.query.federalSubjectId = nil
                    }
            }
            // MARK: Federal Subject
            <<< SearchPushRow<FederalSubject_>("federalBody") {
                $0.selectorTitle = "Выберите федеральный орган власти"
                var feds = federalSubjects
                let absentValue = FederalSubject_(__withFakeName: anyoneName)
                feds.insert(absentValue, at: 0)
                $0.options = feds
                // Value selected from a reference category page
                if receivedFederalSubjectId > 0,
                    let realm = try? Realm(),
                    let fedsub = realm.object(ofType: FederalSubject_.self, forPrimaryKey: receivedFederalSubjectId) {
                    $0.value = fedsub
                    self.query.federalSubjectId = receivedFederalSubjectId
                } else {
                    $0.value = absentValue
                    self.query.federalSubjectId = nil
                }

                $0.hidden = Condition.function(["federalSwitch"], { form in
                    return !((form.rowBy(tag: "federalSwitch") as? SwitchRow)?.value ?? true)
                })

                $0.displayValueFor = {
                    if let name = $0?.name, name != self.anyoneName, let current = $0?.isCurrent {
                        return "\(current ? "[Дейс.]" : "[Бывш.]") \(name) "
                    }
                    return self.anyoneName
                }

                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id,
                        let fedSub = try? Realm().object(ofType: FederalSubject_.self, forPrimaryKey: id), let existingFedSubj = fedSub {
                        self?.query.federalSubjectId = existingFedSubj.id
                    }

            }

            // MARK: Regional Subject switch
            <<< SwitchRow("regionalSwitch") {
                $0.title = "Региональный орган зак. власти"
                $0.value = receivedRegionalSubjectId > 0 ? true : false
                $0.cell.switchControl.tintColor = UIColor.ztint
                $0.cell.switchControl.onTintColor = UIColor.ztint
                }.onChange { [weak self] (row) in
                    if row.value ?? false {
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
                let absentValue = RegionalSubject_(__withFakeName: anyoneName)
                regs.insert(absentValue, at: 0)
                $0.options = regs

                // Value selected from a reference category page
                if receivedRegionalSubjectId > 0,
                    let realm = try? Realm(),
                    let regsub = realm.object(ofType: RegionalSubject_.self, forPrimaryKey: receivedRegionalSubjectId) {
                    $0.value = regsub
                    self.query.regionalSubjectId = receivedRegionalSubjectId
                } else {
                    $0.value = absentValue
                    self.query.regionalSubjectId = nil;
                }

                $0.hidden = Condition.function(["regionalSwitch"], { form in
                    return !((form.rowBy(tag: "regionalSwitch") as? SwitchRow)?.value ?? false)
                })
                $0.displayValueFor = {
                    if let name = $0?.name, name != self.anyoneName, let current = $0?.isCurrent {
                        return "\(current ? "[Дейс.]" : "[Бывш.]") \(name) "
                    }
                    return self.anyoneName
                }

                }
                .onChange { [weak self] row in
                    if row.value?.id == 0 { // Absent value
                        self?.query.deputyId = nil
                    } else if let id = row.value?.id,
                        let regionalSub = try? Realm().object(ofType: RegionalSubject_.self, forPrimaryKey: id),
                        let existRegSub = regionalSub {
                        self?.query.regionalSubjectId = existRegSub.id
                    }
            }

            +++ Section("Сортировать по:")
            // MARK: Sort order
            <<< PushRow<String>("sortOrder") {
                $0.title = ""
                $0.selectorTitle = "Сортировать по:"
                $0.cell.detailTextLabel?.textColor = UIColor.black
                $0.options = BillSearchQuerySortType.allValues.map {
                    $0.description
                }
                $0.value = BillSearchQuerySortType.last_event_date.description  // initially selected
                }.onChange { [weak self] row in
                    self?.query.setSortOrder(withDescription: row.value ?? "")
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
            (segue.destination as? SearchResultsTableViewController)?.isPrefetched = billsAlreadyFetched

        }
    }


    // MARK: - Request Preprocessing

    func preprocessRequest(usingQuery: BillSearchQuery, afterSeconds: Double) {
        Dispatcher.shared.dispatchBillsPrefetching(afterSeconds: afterSeconds) { [weak self] in
            guard let existingQuery = self?.query else {
                assertionFailure("∆ preprocessRequest: query missing")
                return
            }
            UserServices.downloadBills(withQuery: existingQuery) { (resultBills, totalCount) in
                let realm = try? Realm()
                let newList = BillsList_(withName: BillsListType.mainSearch, totalCount: totalCount)
                newList.bills.append(objectsIn: resultBills)
                try? realm?.write {
                    realm?.add(newList, update: true)
                }
                self?.billsAlreadyFetched = true
            }
        }
    }
}
