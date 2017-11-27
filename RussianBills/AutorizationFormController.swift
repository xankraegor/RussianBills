//
//  AuthorizationFormController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Eureka
import FirebaseAuth
import FirebaseDatabase

final class AuthFormController: FormViewController {

    var enteredEmail: String? = nil
    var enteredPassword: String? = nil
    var authHandle: AuthStateDidChangeListenerHandle?
    var authStatus: AuthStatus = .denied

    // MARK: - Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        setupAuthHandle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }

    // MARK: - Authorization routine

    func setupAuthHandle() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.handleAuthResponse(error: nil, user: user)
        }
    }

    func performAuthorization() {
        if let email = enteredEmail, let pass = enteredPassword, let statusRow = self.form.rowBy(tag: "authStatus") as? LabelRow {
            statusRow.title = "Осуществляю вход..."
            Auth.auth().signIn(withEmail: email, password: pass, completion: { [weak self] (user, error) in
                self?.handleAuthResponse(error: error, user: user)
            })
        }
    }

    func performLogout() {
        try? Auth.auth().signOut()
    }

    // MARK: - Form contents

    func setupForm() {

        form +++ Section("loginSection") { section in
            section.header?.title = ""
        }
            <<< LabelRow("authStatus"){ row in
                row.title = authStatus.rawValue
                row.cell.textLabel?.numberOfLines = 0
            }
            <<< EmailRow("emailRow"){ row in
                row.title = "Адрес"
                row.placeholder = "test@test.com"
                row.add(rule: RuleRequired())
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChange
                row.disabled = Condition.function([], { [weak self] (_) -> Bool in
                    return self?.authStatus == .processing || self?.authStatus == .successful
                })
                }.onChange { [weak self] row in
                    let charactersCount = row.value?.count ?? 0
                    if charactersCount > 0 {
                        self?.enteredEmail = row.value ?? ""
                    } else {
                        self?.enteredEmail = nil
                    }
            }

            <<< LabelRow() { row in
                row.title = "Некорректный адрес"
                row.cell.textLabel?.textColor = UIColor.red
                row.hidden = Condition.function(["emailRow"], { (form) -> Bool in
                    guard let emailRow = (form.rowBy(tag: "emailRow") as? EmailRow) else {
                        return true
                    }

                    return emailRow.isValid
                })
            }

            <<< PasswordRow("passwordRow"){ row in
                row.title = "Пароль"
                row.placeholder = "password"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                row.disabled = Condition.function([], { [weak self] (_) -> Bool in
                    return self?.authStatus == .processing
                })
                row.hidden = Condition.function([], { [weak self] (_) -> Bool in
                    return self?.authStatus == .successful
                })
                }.onChange { [weak self] row in
                    let charactersCount = row.value?.count ?? 0
                    if charactersCount > 0 {
                        self?.enteredPassword = row.value ?? ""
                    } else {
                        self?.enteredPassword = nil
                    }
            }

            <<< ButtonRow("loginButtonRow") { row in
                row.disabled = Condition.function(["emailRow", "passwordRow"], { [weak self] (form) -> Bool in

                    switch self!.authStatus {
                    case .successful:
                        return false
                    case .processing:
                        return true
                    case .denied:
                        break
                    }

                    guard let emailRow = form.rowBy(tag: "emailRow") as? EmailRow, let passwordRow = form.rowBy(tag: "passwordRow") as? PasswordRow else {
                        return false
                    }

                    guard emailRow.isValid && passwordRow.isValid else {
                        return false
                    }

                    let emailLength = emailRow.value?.count ?? 0
                    let passwordLength = passwordRow.value?.count ?? 0
                    return emailLength < 1 || passwordLength < 1
                })
                row.title = "Войти"
                }.onCellSelection({ [weak self] (cell, row) in
                    if self?.authStatus != .successful {
                        self?.performAuthorization()
                    } else {
                        self?.performLogout()
                    }
                })

            +++ Section("signUpSection") { section in
                section.header?.title = "Зарегистрироваться"
            }
            <<< EmailRow("emailRowSignUp"){ row in
                row.title = "Адрес"
                row.placeholder = "test@test.com"
                row.add(rule: RuleRequired())
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChange
                }

            <<< PasswordRow("passwordRowSignUp"){ row in
                row.title = "Использовать пароль"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< PasswordRow("confirmPasswordRowSignUp"){ row in
                row.title = "Повторите пароль"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }

            <<< ButtonRow("singUpButtonRow") { row in
                row.title = ""
                }.onCellSelection({ [weak self] (cell, row) in
                    print("SignUp button pressed")
                })
    }

    func handleAuthResponse(error: Error?, user: User?) {

        let statusRow = self.form.rowBy(tag: "authStatus") as! LabelRow
        let emailRow = self.form.rowBy(tag: "emailRow") as! EmailRow
        let passRow = self.form.rowBy(tag: "passwordRow") as! PasswordRow
        let buttonRow = self.form.rowBy(tag: "loginButtonRow") as! ButtonRow

        if let err = error as? AuthErrorCode {
            authStatus = .denied
            switch err {
            case .userDisabled:
                statusRow.title = "Учётная запись заблокирована"
            case .operationNotAllowed:
                statusRow.title = "Учётная запись не подтверждена"
            case .invalidEmail:
                statusRow.title = "Неправильный адрес электронной почты"
            case .wrongPassword:
                statusRow.title = "Неправильный пароль"
            case .userNotFound:
                statusRow.title = "Пользователь не найден"
            case .networkError:
                statusRow.title = "Сетевое соединение недоступно"
            case .keychainError:
                statusRow.title = "Ошибка при обращении к связке ключей iOS: \(error?.localizedDescription ?? "детальное описание отсутствует")"
            case .internalError:
                statusRow.title = "Внутренняя ошибка сервиса"
            default:
                statusRow.title = "Ошибка: \(err.rawValue)"
            }
            emailRow.disabled = false
            passRow.hidden = false
            buttonRow.title = "Войти"

        } else if let usr = user {
            authStatus = .successful
            statusRow.title = "Успешно авторизован"
            emailRow.disabled = true
            emailRow.value = usr.email
            passRow.hidden = true
            buttonRow.title = "Выйти"

//            SyncMan.shared.updateFirebaseFavoriteRecords()
        }

        tableView.reloadData()
    }
    
}
