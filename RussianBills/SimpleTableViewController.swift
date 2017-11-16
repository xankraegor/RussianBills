//
//  TopicsViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class SimpleTableViewController: UITableViewController, UISearchResultsUpdating {

    var objectsToDisplay: SimpleTableViewControllerSelector?

    let realm = try? Realm()
    var realmNotificationToken: NotificationToken? = nil
    var objects: Results<Object>?

    var filteredObjects: [Object]?
    var isFiltering: Bool { return searchController.isActive && !searchBarIsEmpty() }

    let searchController = UISearchController(searchResultsController: nil)


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard objectsToDisplay != nil else {
            dismiss(animated: true, completion: nil)
            return
        }

        objects = realm?.objects(objectsToDisplay!.typeUsedForObjects).sorted(byKeyPath: "name", ascending: true)
        realmNotificationToken = objects!.observe {
            [weak self] (_)->Void in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = objectsToDisplay!.fullDescription
        self.navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        switch objectsToDisplay! {
        case .lawClasses:
            UserServices.downloadLawCalsses { [weak self] in
                self?.updateTableWithNewData()
            }
        case .topics:
            UserServices.downloadTopics { [weak self] in
                self?.updateTableWithNewData()
            }
        case .committees:
            UserServices.downloadComittees { [weak self] in
                self?.updateTableWithNewData()
            }
        case .federalSubjects:
            UserServices.downloadFederalSubjects { [weak self] in
                self?.updateTableWithNewData()
            }
        case .regionalSubjects:
            UserServices.downloadFederalSubjects { [weak self] in
                self?.updateTableWithNewData()
            }
        case .instances:
            UserServices.downloadInstances { [weak self] in
                self?.updateTableWithNewData()
            }
        case .deputees:
            UserServices.downloadInstances() { [weak self] in
                self?.updateTableWithNewData()
            }
        }
    }


    deinit {
        realmNotificationToken?.invalidate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredObjects?.count ?? 0
        } else {
            return objects?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch objectsToDisplay! {

        // Legislative initiative bodies
        case .federalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = isFiltering ? filteredObjects![indexPath.row] as! FederalSubject_ : objects![indexPath.row] as! FederalSubject_
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            cell.accessoryType = .disclosureIndicator
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell

        case .regionalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = isFiltering ? filteredObjects![indexPath.row] as! RegionalSubject_ : objects![indexPath.row] as! RegionalSubject_
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            cell.accessoryType = .disclosureIndicator
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell

        case .deputees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeputeesCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Deputy_ :  objects![indexPath.row] as! Deputy_
            cell.textLabel?.text = objct.name
            cell.detailTextLabel?.text = (objct.isCurrent ? "✅ Действующий " : "⏹ Бывший ") + objct.position
            cell.accessoryType = .disclosureIndicator
            return cell

        case .lawClasses:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! LawClass_ : objects![indexPath.row] as! LawClass_
            cell.textLabel?.text = objct.name
            return cell

        case .topics:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Topic_: objects![indexPath.row] as! Topic_
            cell.textLabel?.text = objct.name
            return cell

        case .instances:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Instance_ : objects![indexPath.row] as! Instance_
            cell.textLabel?.text = objct.name
            return cell

        case .committees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Comittee_ : objects![indexPath.row] as! Comittee_
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell
        }

    }

    // MARK: - Helper functions

    private func updateTableWithNewData() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
    }

    func searchBarIsEmpty() -> Bool {
        let isEmpty = searchController.searchBar.text?.isEmpty ?? true

        if isEmpty {
            filteredObjects = nil
        }

        return isEmpty
    }

    // MARK: - Search Controller Updating

    internal func updateSearchResults(for searchController: UISearchController) {
        if let filterText = searchController.searchBar.text {

            var newFilterdObjects: [Object] = []

            switch self.objectsToDisplay! {
            case .committees:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: Comittee_.self, applyingFilter: filterText)!)
            case .deputees:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: Deputy_.self, applyingFilter: filterText)!)
            case .federalSubjects:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: FederalSubject_.self, applyingFilter: filterText)!)
            case .instances:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: Instance_.self, applyingFilter: filterText)!)
            case .lawClasses:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: LawClass_.self, applyingFilter: filterText)!)
            case .regionalSubjects:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: RegionalSubject_.self, applyingFilter: filterText)!)
            case .topics:
                newFilterdObjects = Array(Realm.loadObjectsWithFilter(ofType: Topic_.self, applyingFilter: filterText)!)
            }

            self.filteredObjects = newFilterdObjects
            self.tableView.reloadData()
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch objectsToDisplay! {
        case .federalSubjects, .regionalSubjects, .deputees:
            return true
        default:
            return false
        }
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? LegislativeSubjTableViewController,
            let selectedRow = tableView.indexPathForSelectedRow?.row, let obj = objects else {
                return
        }

        guard let source = isFiltering ? filteredObjects : Array(obj) else {
            return
        }

        switch objectsToDisplay! {
        case .federalSubjects:
            if let object = source[selectedRow] as? FederalSubject_ {
                dest.id = object.id
                dest.subjectType = LegislativeSubjectType.federalSubject
            }
        case .regionalSubjects:
            if let object = source[selectedRow] as? RegionalSubject_ {
                dest.id = object.id
                dest.subjectType = LegislativeSubjectType.regionalSubject
            }
        case .deputees:
            if let object = source[selectedRow] as? Deputy_ {
                dest.id = object.id
                dest.subjectType = LegislativeSubjectType.deputy
            }
        default:
            break
        }



    }
}

