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
    var filteredObjects: [Object]?
    let searchController = UISearchController(searchResultsController: nil)
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if objectsToDisplay == nil {
            dismiss(animated: true, completion: nil)
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
    }

    override func viewDidAppear(_ animated: Bool) {
        switch objectsToDisplay! {
        case .lawClasses:
            UserServices.downloadAndSaveLawCalsses { [weak self] in
                self?.updateTableWithNewData()
            }
        case .topics:
            UserServices.downloadAndSaveTopics { [weak self] in
                self?.updateTableWithNewData()
            }
        case .committees:
            UserServices.downloadAndSaveComittees { [weak self] in
                self?.updateTableWithNewData()
            }
        case .federalSubjects:
            UserServices.downloadAndSaveFederalSubjects { [weak self] in
                self?.updateTableWithNewData()
            }
        case .regionalSubjects:
            UserServices.downloadAndSaveFederalSubjects { [weak self] in
                self?.updateTableWithNewData()
            }
        case .instances:
            UserServices.downloadAndSaveInstances { [weak self] in
                self?.updateTableWithNewData()
            }
        case .deputees:
            UserServices.downloadAndSaveInstances() { [weak self] in
                self?.updateTableWithNewData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredObjects?.count ?? 0
        } else {
            return RealmCoordinator.countObjects(ofType: objectsToDisplay!.typeUsedForObjects)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch objectsToDisplay! {

        case .lawClasses:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! LawClass_ : RealmCoordinator.loadObject(LawClass_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
            return cell

        case .topics:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Topic_: RealmCoordinator.loadObject(Topic_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
            return cell

        case .instances:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Instance_ : RealmCoordinator.loadObject(Instance_.self, sortedBy: "id", ascending: false, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
            return cell

        case .federalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = isFiltering ? filteredObjects![indexPath.row] as! FederalSubject_ : RealmCoordinator.loadObject(FederalSubject_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell

        case .regionalSubjects:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = isFiltering ? filteredObjects![indexPath.row] as! RegionalSubject_ : RealmCoordinator.loadObject(RegionalSubject_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell

        case .committees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComitteesCellId", for: indexPath) as! NameStartEndTableViewCell
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Comittee_ : RealmCoordinator.loadObject(Comittee_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.nameLabel.text = objct.name
            cell.beginDateLabel.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: objct.startDate).description()
            if objct.isCurrent {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: objct.stopDate).description()
            }
            return cell
            
        case .deputees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeputeesCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Deputy_ :  RealmCoordinator.loadObject(Deputy_.self, sortedBy: "name", ascending: true, byIndex: indexPath.row)
            cell.textLabel?.text = objct.name
            cell.detailTextLabel?.text = (objct.isCurrent ? "✅ Действующий " : "⏹ Бывший ") + objct.position
            return cell
        }

    }

    // MARK: - Helper functions

    private func updateTableWithNewData() {
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
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

            var objects: [Object] = []

            switch self.objectsToDisplay! {
            case .committees:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: Comittee_.self, applyingFilter: filterText)!)
            case .deputees:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: Deputy_.self, applyingFilter: filterText)!)
            case .federalSubjects:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: FederalSubject_.self, applyingFilter: filterText)!)
            case .instances:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: Instance_.self, applyingFilter: filterText)!)
            case .lawClasses:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: LawClass_.self, applyingFilter: filterText)!)
            case .regionalSubjects:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: RegionalSubject_.self, applyingFilter: filterText)!)
            case .topics:
                objects = Array(RealmCoordinator.loadObjectsWithFilter(ofType: Topic_.self, applyingFilter: filterText)!)
            }

            self.filteredObjects = objects
            self.tableView.reloadData()
        }
    }
}

