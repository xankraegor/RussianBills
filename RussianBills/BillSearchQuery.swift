//
//  BillSearchQuery.swift
//  RussianBills
//
//  Created by Xan Kraegor on 05.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

// Законопроект

struct BillSearchQuery {

    /// ПАРАМЕТРЫ С ЗАДАННЫМИ ЗНАЧЕНИЯМИ

    var lawType: LawType?
    var status: BillStatus?

    /// ПАРАМЕТРЫ С ПРОИЗВОЛЬНЫМИ ЗНАЧЕНИЯМИ

    var name: String?
    // TODO: - Test number parameter in request, seems to be an Integer in response (how ???)
    var number: String?
    var registrationStart: String?
    var registrationEnd: String?
    var appendedDocumentNumber: Int?

    /// ПАРАМЕТРЫ СО ЗНАЧЕНИЯМИ ИЗ СПРАВОЧНИКОВ

    var topic: Topic_?
    var lawClass: LawClass_?
    var federalSubject: FederalSubject_?
    var regionalSubject: RegionalSubject_?
    var deputy: Deputy_?
    var comitteeResponsible: Comittee_?
    var comitteeCoexecutor: Comittee_?
    var comitteeProfile: Comittee_?

    /// ПАРАМЕТРЫ ПОИСКА ПО СОБЫТИЯМ
    /// По каждому из законопроектов в системе АИС «Законопроект» хранятся все события, произошедшие с ним. В запросе доступна фильтрация законопроектов по параметрам, связанными с событиями. Для активации поиска по данным параметрам обязательно указание режима поиска по событиям, за что отвечает параметр search_mode.

    /// search_mode — режим поиска по событиям законопроекта, возможны следующие значения:
    /// 1 — поиск по всем событиям
    /// 2 — поиск по последнему событию
    /// 3 — поиск по ожидаемому событию
    /// После указания search_mode активируются следующие параметры поиска:
    /// event_start — минимальная дата события в формате ГГГГ-ММ-ДД
    /// event_end — максимальная дата события в формате ГГГГ-ММ-ДД
    /// instance — идентификатор инстанции рассмотрения
    /// stage — идентификатор стадии рассмотрения
    /// phase — идентификатор события рассмотрения
    /// Параметры stage и phase взаимоисключающие. Параметр phase позволяет фильтровать по типу события, т.е. производить более точную фильтрацию по сравнению с параметром stage.

    /// ПРОЧИЕ ПАРАМЕТРЫ
    var pageNumber: UInt?
    var pageLimit: BillSearchQueryPageLimit?
    var sortType: BillSearchQuerySortType?

    // MARK: - Methods
    
    func hasAnyFilledField()->Bool {
        // TODO: Mirroring solution
        //        let mirror = Mirror(reflecting: self)
        //        let count = mirror.children.filter{$0.value is Optional<Any>.Type}.count
        //        debugPrint("BillSearchQuery has \(count) filled in fields")
        //        return count > 0

        return (name != nil) || (number != nil)
    }

    func produceFilter()->String? {
        // TODO: Mirroring solution?
        var output = ""

        func add(toText: inout String, text: String) {
            if output.characters.count > 0 {
                toText = toText + " && " + text
            } else {
                toText = text
            }
        }

        if name != nil {
            add(toText: &output, text: "name contains '\(name!)'")
        }
        if number != nil {
            add(toText: &output, text: "number == \(number!)")
        }

        return output
    }

}
