//
//  LegislativeSubjTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit

final class LegislativeSubjTableViewController: UITableViewController {

    var subjectType: LegislativeSubjectType? = nil
    var id: Int? = nil

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var isCurrentLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var showOnMapLabel: UILabel!

    var address: String = "" {
        didSet {
            if address.count > 0 {
                lookupForCoordinates(withAddress: address)
                addressLabel.text = address
            } else {
                addressLabel.text = "Адрес отсутствует"
            }
        }
    }

    var organizationName: String = ""

    var locationForMap: CLLocation?



    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isToolbarHidden = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30

        guard let subjectType = subjectType, let id = id else {
            return
        }

        if let item = subjectType.item(byId: id) {
            setMainLabels(forItem: item)
        }
    }


    // MARK: - Helper functions

    func setMainLabels(forItem item: Object) {
        if let fedSubj = item as? FederalSubject_ {
            nameLabel.text = fedSubj.name
            organizationName = fedSubj.name
            typeLabel.text = "Федеральный орган власти"
            var currentText = fedSubj.isCurrent ? "Действует c " : "Действовал c "
            currentText.append(contentsOf: fedSubj.startDate)
            if !fedSubj.isCurrent {
                currentText.append(contentsOf: " по \(fedSubj.stopDate.isoDateToReadableDate() ?? fedSubj.stopDate)")
            }
            isCurrentLabel.text = currentText

            switch fedSubj.id {
            case 6231000:    //Верховный Суд РФ
                address = "121260, Москва, ул. Поварская, 15"
            case 6231100:    //Высший Арбитражный Суд РФ
                address = "101000, Москва, Малый Харитоньевский пер., 12"
            case 6230900:    //Конституционный Суд РФ
                address = "190000, Санкт-Петербург, Сенатская пл., 1"
            case 6230800:    //Правительство РФ
                address = "103274, Москва, Краснопресненская наб., 2"
            case 6230500:    //Президент РФ
                address = "101000, Москва, Старая Площадь, 6 стр. 1"
            case 6230600:    //Совет Федерации РФ
                address = "103426, Москва, ул. Большая Дмитровка, 26"
            default:
                break
            }

        } else if let regSubj = item as? RegionalSubject_ {
            nameLabel.text = regSubj.name
             organizationName = regSubj.name
            typeLabel.text = "Региональный орган власти"
            var currentText = regSubj.isCurrent ? "Действует c " : "Действовал c "
            currentText.append(contentsOf: regSubj.startDate.isoDateToReadableDate() ?? regSubj.startDate)
            if !regSubj.isCurrent {
                currentText.append(contentsOf: " по \(regSubj.stopDate.isoDateToReadableDate() ?? regSubj.stopDate)")
            }
            isCurrentLabel.text = currentText
            if let data = regionalSubjectsData[regSubj.id], let addr = data["address"] {
                address = addr
            } else {
                address = ""
            }

        } else if let deputy = item as? Deputy_ {
            nameLabel.text = deputy.name
            typeLabel.text = deputy.position
            isCurrentLabel.text = deputy.isCurrent ? "Полномочия действуют" : "Срок полномочий истёк"
            if deputy.position.lowercased().contains("депутат") {
                address = "103265, Москва, ул. Охотный ряд, 1"
                organizationName = "Государственная Дума РФ"
            } else if deputy.position.lowercased().contains("член") {
                address = "103426, Москва, ул. Большая Дмитровка, 26"
                organizationName = "Совет Федерации РФ"
            }
        }
    }

    // MARK: - Location Services

    func lookupForCoordinates(withAddress address: String) {
        LocationManager.instance.geocode(address: address) { [weak self] (placemark) in
            self?.locationForMap = placemark?.location
            self?.showOnMapLabel.isEnabled = self?.locationForMap != nil ? true : false

            if let pm = placemark {
                print("Name: \(pm.name ?? "")")
                print("abbreviated country name: \(pm.isoCountryCode ?? "")")
                print("country name: \(pm.country ?? "")")
                print("postal code: \(pm.postalCode ?? "")")
            }
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showOnMapSegue" {
            return self.locationForMap != nil
        }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOnMapSegue" {
            let dest = segue.destination as! OnMapViewController
            dest.locationToDisplay = self.locationForMap!
            dest.nameToDisplay = organizationName
        }
    }

}
