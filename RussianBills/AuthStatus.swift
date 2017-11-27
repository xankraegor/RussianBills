//
//  AuthStatus.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

enum AuthStatus: String {
    case processing = "Осуществляется вход..."
    case denied = "Не авторизован"
    case successful = "Авторизация успешна"
}
