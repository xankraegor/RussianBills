//
// RequestRouterBillParameters.swift
// RussianBills
//
// Created by Xan Kraegor on 04.07.2017.
// Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension RequestRouter {

    /// Parameters for bill search query
    internal static func generateBillRequestParameters(forQuery query: BillSearchQuery) -> [String: Any] {
        var dict = Dictionary<String, Any>()

        /// ПАРАМЕТРЫ С ЗАДАННЫМИ ЗНАЧЕНИЯМИ

        /// law_type — тип законопроекта, возможны следующие значения:
        /// 38 — Федеральный закон
        /// 39 — Федеральный конституционный закон
        /// 41 — Закон о поправках к Конституции РФ
        if let lawType = query.lawType {
            dict["law_type"] = lawType.rawValue
        }

        /// status — статус законопроекта, возможны следующих значения:
        /// 1 — внесенные в ГД
        /// 2 — находящиеся на рассмотрении ГД
        /// 3 — входящие в примерную программу
        /// 4 — входящие в программы комитетов
        /// 5 — внесенные в ГД помимо программ
        /// 6 — рассмотрение которых завершено
        /// 7 — подписанные Президентом РФ
        /// 8 — отклоненные (снятые) ГД
        /// 9 — отозванные или возвращенные СПЗИ
        /// 99 — рассмотрение которых завершено по прочим причинам
        if let status = query.status {
            dict["status"] = status.rawValue
        }

        /// ПАРАМЕТРЫ С ПРОИЗВОЛЬНЫМИ ЗНАЧЕНИЯМИ

        /// name — название законопроекта
        if let name = query.name {
            dict["name"] = name
        }

        /// number — номер законопроекта
        if let number = query.number {
            dict["number"] = number
        }

        /// registration_start — минимальная дата регистрации законопроекта в формате ГГГГ-ММ-ДД
        if let startDate = query.registrationStart {
            dict["registration_start"] = startDate
        }

        /// registration_end — максимальная дата регистрации законопроекта в формате ГГГГ-ММ-ДД
        if let endDate = query.registrationEnd {
            dict["registration_end"] = endDate
        }

        /// document_number — номер документа, связанного с законопроектом. Номер можно увидеть, например, в правой колонке на странице законопроекта в АСОЗД
        if let docNr = query.appendedDocumentNumber {
            dict["document_number"] = docNr
        }

        /// ПАРАМЕТРЫ СО ЗНАЧЕНИЯМИ ИЗ СПРАВОЧНИКОВ

        /// topic — идентификатор тематического блока
        if let topic = query.topic {
            dict["topic"] = topic.id
        }

        /// class — идентификатор отрасли законодательства
        if let lawClass = query.lawClass {
            dict["class"] = lawClass.id
        }

        /// federal_subject — идентификатор федерального органа власти — субъекта законодательной инициативы
        if let fedSubj = query.federalSubjectId {
            dict["federal_subject"] = fedSubj
        }

        /// regional_subject — идентификатор регионального органа власти — субъекта законодательной инициативы
        if let regSubj = query.regionalSubjectId {
            dict["regional_subject"] = regSubj
        }

        /// deputy — идентификатор депутата ГД или члена СФ — субъекта законодательной инициативы
        if let deputy = query.deputyId {
            dict["deputy"] = deputy
        }

        /// responsible_committee — идентификатор ответственного комитета
        if let respComittee = query.committeeResponsibleId {
            dict["responsible_committee"] = respComittee
        }

        /// soexecutor_committee — идентификатор комитета-соисполнителя
        if let coexecCommittee = query.committeeCoexecutorId {
            dict["soexecutor_committee"] = coexecCommittee
        }

        /// profile_committee — идентификатор профильного комитета
        if let profileCommittee = query.committeeProfileId {
            dict["profile_committee"] = profileCommittee
        }

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

        /// page — номер запрашиваемой страницы результатов, по умолчанию равно 1
        dict["page"] = query.pageNumber
        /// limit — количество результатов на странице, допустимые значения: 5, 10, 20 (по умолчанию)
        dict["limit"] = query.pageLimit

        /// sort — способ сортировки результатов, по умолчанию равно last_event_date, допустимые значения:
        /// name — по названию законопроекта
        /// number — по номеру законопроекта
        /// date — по дате внесения в ГД (по убыванию)
        /// date_asc — по дате внесения в ГД (по возрастанию)
        /// last_event_date — по дате последнего события (по убыванию)
        /// last_event_date_asc — по дате последнего события (по возрастанию)
        /// responsible_committee — по ответственному комитету
        dict["sort"] = query.sortType.rawValue

        return dict
    }
}
