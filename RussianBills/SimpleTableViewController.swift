//
//  TopicsViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class SimpleTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var objectsToDisplay: SimpleTableViewControllerSelector?

    let realm = try? Realm()
    var realmNotificationToken: NotificationToken? = nil

    lazy var objects: Results<Object>? = {
        if objectsToDisplay == .dumaDeps {
            return realm?.objects(objectsToDisplay!.typeUsedForObjects).filter("position CONTAINS[cd] 'депутат'").sorted(byKeyPath: "name", ascending: true)
        } else if objectsToDisplay == .councilMems {
            return realm?.objects(objectsToDisplay!.typeUsedForObjects).filter("position CONTAINS[cd] 'член'").sorted(byKeyPath: "name", ascending: true)
        } else {
            return realm?.objects(objectsToDisplay!.typeUsedForObjects).sorted(byKeyPath: "name", ascending: true)
        }
    }()

    var filteredObjects: [Object]?
    var isFiltering: Bool {
        return (searchController.isActive && !searchBarIsEmpty()) || searchController.searchBar.selectedScopeButtonIndex != 0
    }

    let searchController = UISearchController(searchResultsController: nil)


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard objectsToDisplay != nil else {
            dismiss(animated: true, completion: nil)
            return
        }

        realmNotificationToken = objects!.observe {
            [weak self] (_)->Void in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = objectsToDisplay!.fullDescription
        navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        navigationController?.toolbar.isHidden = true
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
        case .dumaDeps, .councilMems:
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

        case .dumaDeps, .councilMems:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeputeesCellId", for: indexPath)
            let objct = isFiltering ? filteredObjects![indexPath.row] as! Deputy_ :  objects![indexPath.row] as! Deputy_
            cell.textLabel?.text = objct.name
            cell.detailTextLabel?.text = (objct.isCurrent ? "✅ Действующий " : "⏹ Бывший ") + objct.position
            cell.accessoryType = .disclosureIndicator
            return cell

            // Other Reference categories
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
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal

        if objectsToDisplay?.typeUsedForObjects === FederalSubject_.self ||
            objectsToDisplay?.typeUsedForObjects === RegionalSubject_.self ||
            objectsToDisplay?.typeUsedForObjects === Deputy_.self
            {
            searchController.searchBar.scopeButtonTitles = ["Все", "Действующие", "Не действ."]
//            searchController.searchBar.showsScopeBar = true
            searchController.searchBar.sizeToFit()
        }

        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }

    func updateSearchResults() {
        let filterText = searchController.searchBar.text

        var current: Bool? = nil
        if searchController.searchBar.selectedScopeButtonIndex == 1 {
            current = true
        }

        if searchController.searchBar.selectedScopeButtonIndex == 2 {
            current = false
        }

        var newFilterdObjects: [Object] = []

        switch self.objectsToDisplay! {
        case .committees:
            newFilterdObjects = Array(realm!.loadFilteredObjects(Comittee_.self, orString: filterText, andCurrent: current)!)
        case .dumaDeps:
            newFilterdObjects = Array(realm!.loadFilteredObjects(Deputy_.self, orString: filterText, andCurrent: current, dumaDeps: true)!)
        case .councilMems:
            newFilterdObjects = Array(realm!.loadFilteredObjects(Deputy_.self, orString: filterText, andCurrent: current, dumaDeps: false)!)
        case .federalSubjects:
            newFilterdObjects = Array(realm!.loadFilteredObjects(FederalSubject_.self, orString: filterText, andCurrent: current)!)
        case .instances:
            newFilterdObjects = Array(realm!.loadFilteredObjects(Instance_.self, orString: filterText, andCurrent: current)!)
        case .lawClasses:
            newFilterdObjects = Array(realm!.loadFilteredObjects(LawClass_.self, orString: filterText, andCurrent: current)!)
        case .regionalSubjects:
            newFilterdObjects = Array(realm!.loadFilteredObjects(RegionalSubject_.self, orString: filterText, andCurrent: current)!)
        case .topics:
            newFilterdObjects = Array(realm!.loadFilteredObjects(Topic_.self, orString: filterText, andCurrent: current)!)
        }

        self.filteredObjects = newFilterdObjects
        self.tableView.reloadData()
    }

    // MARK: - Search Controller Updating

    internal func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults()
    }

    // MARK: - Search Bar Delegate

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchController.searchBar.resignFirstResponder()
        updateSearchResults()
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch objectsToDisplay! {
        case .federalSubjects, .regionalSubjects, .dumaDeps, .councilMems:
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
        case .dumaDeps, .councilMems:
            if let object = source[selectedRow] as? Deputy_ {
                dest.id = object.id
                dest.subjectType = LegislativeSubjectType.deputy
            }
        default:
            break
        }
    }
}

