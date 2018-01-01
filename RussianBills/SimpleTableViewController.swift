//
//  SimpleTableViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 07.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

final class SimpleTableViewController: UITableViewController {

    var objectsToDisplay: SimpleTableViewControllerSelector?

    let realm = try? Realm()
    var realmNotificationToken: NotificationToken?

    lazy var objects: Results<Object>? = {
        if objectsToDisplay == .dumaDeputees {
            return realm?.objects(objectsToDisplay!.typeUsedForObjects).filter("position CONTAINS[cd] 'депутат'").sorted(byKeyPath: "name", ascending: true)
        } else if objectsToDisplay == .councilMembers {
            return realm?.objects(objectsToDisplay!.typeUsedForObjects).filter("position CONTAINS[cd] 'член'").sorted(byKeyPath: "name", ascending: true)
        } else {
            return realm?.objects(objectsToDisplay!.typeUsedForObjects).sorted(byKeyPath: "name", ascending: true)
        }
    }()

    var filteredObjects: [Object]?

    var isFiltering: Bool {
        let searchBarIsEmpty = searchController.searchBar.text?.isEmpty ?? true
        return (searchController.isActive && !searchBarIsEmpty) || searchController.searchBar.selectedScopeButtonIndex != 0
    }

    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard objectsToDisplay != nil else {
            assertionFailure("∆ 'objectsToDispay' property of a SimpleTableViewController instance is nil")
            dismiss(animated: true, completion: nil)
            return
        }

        setupRealmNotificationToken()
        setupSearchController()
        
        navigationItem.title = objectsToDisplay!.fullDescription
        navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)

        switch objectsToDisplay! {
        case .lawClasses:
            tableView.allowsSelection = false
            UserServices.downloadLawClasses { [weak self] in
                self?.updateTableWithNewData()
            }
        case .topics:
            tableView.allowsSelection = false
            UserServices.downloadTopics { [weak self] in
                self?.updateTableWithNewData()
            }
        case .committees:
            tableView.allowsSelection = false
            UserServices.downloadCommittees { [weak self] in
                self?.updateTableWithNewData()
            }
        case .federalSubjects:
            tableView.allowsSelection = true
            UserServices.downloadFederalSubjects { [weak self] in
                self?.updateTableWithNewData()
            }
        case .regionalSubjects:
            tableView.allowsSelection = true
            UserServices.downloadRegionalSubjects { [weak self] in
                self?.updateTableWithNewData()
            }
        case .instances:
            tableView.allowsSelection = false
            UserServices.downloadInstances { [weak self] in
                self?.updateTableWithNewData()
            }
        case .dumaDeputees, .councilMembers:
            tableView.allowsSelection = true
            UserServices.downloadDeputies() { [weak self] in
                self?.updateTableWithNewData()
            }
        }
    }

    deinit {
        realmNotificationToken?.invalidate()
    }

    // MARK: - Helper functions

    private func updateTableWithNewData() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
    }

    // MARK: - Observation

    func setupRealmNotificationToken() {
        realmNotificationToken = objects?.observe {
            [weak self] (_) -> Void in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch objectsToDisplay! {
        case .federalSubjects, .regionalSubjects, .dumaDeputees, .councilMembers:
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
        case .dumaDeputees, .councilMembers:
            if let object = source[selectedRow] as? Deputy_ {
                dest.id = object.id
                dest.subjectType = LegislativeSubjectType.deputy
            }
        default:
            break
        }
    }
}

// MARK: - Table View Data Source

extension SimpleTableViewController {

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
        switch objectsToDisplay {

        // Legislative initiative bodies
        case .federalSubjects?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommittiesCellId", for: indexPath) as! NameStartEndTableViewCell
            let object = isFiltering ? filteredObjects![indexPath.row] as! FederalSubject_ : objects![indexPath.row] as! FederalSubject_
            cell.nameLabel?.text = object.name
            cell.beginDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: object.startDate).description()
            cell.accessoryType = .disclosureIndicator
            if object.isCurrent {
                cell.endDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: object.stopDate).description()
            }
            return cell

        case .regionalSubjects?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommittiesCellId", for: indexPath) as! NameStartEndTableViewCell
            let object = isFiltering ? filteredObjects![indexPath.row] as! RegionalSubject_ : objects![indexPath.row] as! RegionalSubject_
            cell.nameLabel?.text = object.name
            cell.beginDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: object.startDate).description()
            cell.accessoryType = .disclosureIndicator
            if object.isCurrent {
                cell.endDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: object.stopDate).description()
            }
            return cell

        case .dumaDeputees?, .councilMembers?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeputiesCellId", for: indexPath)
            let object = isFiltering ? filteredObjects![indexPath.row] as! Deputy_ :  objects![indexPath.row] as! Deputy_
            cell.textLabel?.text = object.name
            cell.detailTextLabel?.text = (object.isCurrent ? "✅ Действующий " : "⏹ Бывший ") + object.position
            cell.accessoryType = .disclosureIndicator
            return cell

        // Other Reference categories
        case .lawClasses?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let object = isFiltering ? filteredObjects![indexPath.row] as! LawClass_ : objects![indexPath.row] as! LawClass_
            cell.textLabel?.text = object.name
            return cell

        case .topics?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let object = isFiltering ? filteredObjects![indexPath.row] as! Topic_: objects![indexPath.row] as! Topic_
            cell.textLabel?.text = object.name
            return cell

        case .instances?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCellId", for: indexPath)
            let object = isFiltering ? filteredObjects![indexPath.row] as! Instance_ : objects![indexPath.row] as! Instance_
            cell.textLabel?.text = object.name
            return cell

        case .committees?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommittiesCellId", for: indexPath) as! NameStartEndTableViewCell
            let object = isFiltering ? filteredObjects![indexPath.row] as! Committee_ : objects![indexPath.row] as! Committee_
            cell.nameLabel?.text = object.name
            cell.beginDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.startDate(isoDate: object.startDate).description()
            if object.isCurrent {
                cell.endDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.noEndDate().description()
            } else {
                cell.endDateLabel?.text = NameStartEndTableViewCellDateTextGenerator.endDate(isoDate: object.stopDate).description()
            }
            return cell
        case .none:
            fatalError("Objects to display not provided")
        }
    }

}

// MARK: - UISearchResultsUpdating

extension SimpleTableViewController: UISearchResultsUpdating {

    internal func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults()
    }

}

// MARK: - UISearchBarDelegate

extension SimpleTableViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchController.searchBar.resignFirstResponder()
        updateSearchResults()
    }

}

// MARK: - Other search bar methods

extension SimpleTableViewController {

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        let scb = searchController.searchBar
        scb.searchBarStyle = .default

        scb.barTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)

        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            textfield.tintColor = UIColor.black
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9450980392, alpha: 1)
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }

        if objectsToDisplay?.typeUsedForObjects === FederalSubject_.self ||
            objectsToDisplay?.typeUsedForObjects === RegionalSubject_.self ||
            objectsToDisplay?.typeUsedForObjects === Deputy_.self {
            searchController.searchBar.scopeButtonTitles = ["Все", "Действующие", "Не действ."]
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

        let current: Bool? = {
            switch searchController.searchBar.selectedScopeButtonIndex {
            case 1:
                return true
            case 2:
                return false
            default:
                return nil
            }
        }()

        var newFilteredObjects: [Object] = []

        switch self.objectsToDisplay! {
        case .committees:
            newFilteredObjects = Array(realm!.loadObjects(Committee_.self, fiteredBy: filterText, andAreCurrent: current)!)
        case .dumaDeputees:
            newFilteredObjects = Array(realm!.loadObjects(Deputy_.self, fiteredBy: filterText, andAreCurrent: current, dumaDeputies: true)!)
        case .councilMembers:
            newFilteredObjects = Array(realm!.loadObjects(Deputy_.self, fiteredBy: filterText, andAreCurrent: current, dumaDeputies: false)!)
        case .federalSubjects:
            newFilteredObjects = Array(realm!.loadObjects(FederalSubject_.self, fiteredBy: filterText, andAreCurrent: current)!)
        case .instances:
            newFilteredObjects = Array(realm!.loadObjects(Instance_.self, fiteredBy: filterText, andAreCurrent: current)!)
        case .lawClasses:
            newFilteredObjects = Array(realm!.loadObjects(LawClass_.self, fiteredBy: filterText, andAreCurrent: current)!)
        case .regionalSubjects:
            newFilteredObjects = Array(realm!.loadObjects(RegionalSubject_.self, fiteredBy: filterText, andAreCurrent: current)!)
        case .topics:
            newFilteredObjects = Array(realm!.loadObjects(Topic_.self, fiteredBy: filterText, andAreCurrent: current)!)
        }

        self.filteredObjects = newFilteredObjects
        self.tableView.reloadData()
    }

}
