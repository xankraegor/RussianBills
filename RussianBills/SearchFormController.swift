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
    
    var query = BillSearchQuery() {
        didSet {
            print()
        }
    }
    
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
                    self?.setLawStatus(withStatus: row.value ?? "")
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
            <<< PushRow<String>() {
                $0.title = "Статус"
                $0.selectorTitle = "Выберите статус законопроекта"
                var allValues = (BillStatus.allValues.map{$0.description})
                allValues.append("Любой")
                $0.options = allValues
                $0.value = "Любой"    // initially selected
            }
            
            +++ Section("Дата внесения законопроекта")
            <<< SwitchRow("beginDateRow"){
                $0.title = "Начиная с даты"
                $0.value = false
            }
            <<< DateRow(){
                $0.hidden = Condition.function(["beginDateRow"], { form in
                    return !((form.rowBy(tag: "beginDateRow") as? SwitchRow)?.value ?? false)
                })
                $0.title = ""
                $0.value = Date()
            }
            <<< SwitchRow("endDate"){
                $0.title = "Заканчивая датой"
                $0.value = false
            }
            <<< DateRow(){
                $0.hidden = Condition.function(["endDate"], { form in
                    return !((form.rowBy(tag: "endDate") as? SwitchRow)?.value ?? false)
                })
                $0.title = ""
                $0.value = Date()
            }
    }
    
    
    // MARK: - Updating Query
    
    func setLawStatus(withStatus status: String) {
        switch status {
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
}

