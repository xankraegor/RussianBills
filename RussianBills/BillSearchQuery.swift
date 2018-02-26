//
//  BillSearchself.swift
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
    var number: String?
    var registrationStart: String?
    var registrationEnd: String?
    var appendedDocumentNumber: Int?

    /// ПАРАМЕТРЫ СО ЗНАЧЕНИЯМИ ИЗ СПРАВОЧНИКОВ

    var topic: Topic_?
    var lawClass: LawClass_?
    var federalSubjectId: Int?
    var regionalSubjectId: Int?
    var deputyId: Int?
    var committeeResponsibleId: Int?
    var committeeCoexecutorId: Int?
    var committeeProfileId: Int?

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
    // По умолчанию - первая страница с результатами поиска
    var pageNumber: UInt = 1
    // Используется всегда максимальное значение
    let pageLimit: Int = 20
    // Сортировка по-умолчанию
    var sortType: BillSearchQuerySortType = .last_event_date

    // MARK: - Initialization

    init() {
    }

    init(withNumber: String) {
        self.number = withNumber
    }

    init(withRegistrationEndDate date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.registrationEnd = dateFormatter.string(from: date)
    }

    // MARK: - Methods

    public var hasAnyFieldsFilled: Bool {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            let value = child.value
            let valueMirror = Mirror(reflecting: value)
            if valueMirror.displayStyle == .optional, valueMirror.children.first != nil {
                return true
            }
        }
        return false
    }

    // MARK: - Updating Query

    mutating func setLawType(withDescription description: String) {
        switch description {
        case LawType.federalLaw.description:
            self.lawType = LawType.federalLaw
        case LawType.federalConstitutionalLaw.description:
            self.lawType = LawType.federalConstitutionalLaw
        case LawType.constitutionalAmendment.description:
            self.lawType = LawType.constitutionalAmendment
        default: // "Любой"
            self.lawType = nil
        }
    }

    mutating func setBillStatus(withDescription description: String) {
        switch description {
        case BillStatus.examination.description:
            self.status = BillStatus.examination
        case BillStatus.extraprogrammaticalSubmitted.description:
            self.status = BillStatus.extraprogrammaticalSubmitted
        case BillStatus.finished.description:
            self.status = BillStatus.finished
        case BillStatus.finishedByOtherReasons.description:
            self.status = BillStatus.finishedByOtherReasons
        case BillStatus.inCommitteeProgramme.description:
            self.status = BillStatus.inCommitteeProgramme
        case BillStatus.inProgramme.description:
            self.status = BillStatus.inProgramme
        case BillStatus.recalled.description:
            self.status = BillStatus.recalled
        case BillStatus.rejected.description:
            self.status = BillStatus.rejected
        case BillStatus.signed.description:
            self.status = BillStatus.signed
        case BillStatus.submitted.description:
            self.status = BillStatus.submitted
        default: // "Любой"
            self.status = nil
        }
    }

    mutating func setSortOrder(withDescription description: String) {
        switch description {
        case BillSearchQuerySortType.name.description:
            self.sortType = .name
        case BillSearchQuerySortType.number.description:
            self.sortType = .number
        case BillSearchQuerySortType.date.description:
            self.sortType = .date
        case BillSearchQuerySortType.date_asc.description:
            self.sortType = .date_asc
        case BillSearchQuerySortType.last_event_date_asc.description:
            self.sortType = .last_event_date_asc
        case BillSearchQuerySortType.responsible_committee.description:
            self.sortType = .responsible_committee
        default: //this one used by default in the API
            self.sortType = .last_event_date
        }
    }

}
