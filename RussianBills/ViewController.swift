//
//  ViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 03.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON


class ViewController: UIViewController {

    // MARK:- View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Realm DB Path: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))\n")
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    // MARK:- Test functions

    @IBAction func DEBUGLOADDATA(_ sender: Any) {

        Request.comittees(current: true, completion: { (result: [Comittee_]) in
            RealmCoordinator.save(collection: result)
            print("\nКомитеты ГД РФ, действующие:")
            print(result)
        })

        Request.lawClasses(completion: { (result: [LawClass_]) in
            RealmCoordinator.save(collection: result)
            print("\nОтрасли права:")
            print(result)
        })

        Request.topics(completion: { (result: [Topic_]) in
            RealmCoordinator.save(collection: result)
            print("\nТематические разделы законопроектов:")
            print(result)
        })

        Request.deputies(beginsWithChars: "А", position: .duma, current: true, completion: { (result: [Deputy_]) in
            RealmCoordinator.save(collection: result)
            print("\nДепутаты Госдумы текущего созыва с фамилией, начинающейся на А:")
            print(result)
        })

        Request.federalSubjects(current: true) { (result: [FederalSubject_]) in
            RealmCoordinator.save(collection: result)
            print("\nФедеральные органы власти, действующие:")
            print(result)
        }

        Request.regionalSubjects(current: true) { (result: [RegionalSubject_]) in
            RealmCoordinator.save(collection: result)
            print("\nФедеральные органы власти, действующие:")
            print(result)
        }

        var billQuery = BillSearchQuery()
        billQuery.name = "Курения"
        billQuery.registrationStart = "2000-05-30"
        Request.billSearch(forQuery: billQuery, completion: { (result: [Bill_]) in
            RealmCoordinator.save(collection: result)
            print("\nНекоторые запрошенные законопроекты (представлено \(result.count))")
            print(result)
        })

    }

    @IBAction func DEBUGDELETEDATA(_ sender: Any) {
        RealmCoordinator.deleteEverything()
    }

}
