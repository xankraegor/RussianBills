//
// BillStatus.swift
// RussianBills
//
// Created by Xan Kraegor on 04.07.2017.
// Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

/*
 1 — внесенные в ГД
 2 — находящиеся на рассмотрении ГД
 3 — входящие в примерную программу
 4 — входящие в программы комитетов
 5 — внесенные в ГД помимо программ
 6 — рассмотрение которых завершено
 7 — подписанные Президентом РФ
 8 — отклоненные (снятые) ГД
 9 — отозванные или возвращенные СПЗИ
 99 — рассмотрение которых завершено по прочим причинам
 */

/// Статус рассмотрения законопроекта
enum BillStatus: Int, CustomStringConvertible {
    case submitted = 1
    case examination = 2
    case inProgramme = 3
    case inCommitteeProgramme = 4
    case extraprogrammaticalSubmitted = 5
    case finished = 6
    case signed = 7
    case rejected = 8
    case recalled = 9
    case finishedByOtherReasons = 99

    var description: String {
        switch self {
        case .submitted:
            return "внесенные в ГД"
        case .examination:
            return "находящиеся на рассмотрении ГД"
        case .inProgramme:
            return "входящие в примерную программу"
        case .inCommitteeProgramme:
            return "входящие в программы комитетов"
        case .extraprogrammaticalSubmitted:
            return "внесенные в ГД помимо программ"
        case .finished:
            return "рассмотрение которых завершено"
        case .signed:
            return "подписанные Президентом РФ"
        case .rejected:
            return "отклоненные (снятые) ГД"
        case .recalled:
            return "отозванные или возвращенные СПЗИ"
        case .finishedByOtherReasons:
            return "рассмотрение которых завершено по прочим причинам"
        }
    }

}
