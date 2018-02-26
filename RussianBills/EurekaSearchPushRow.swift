//
//  EurekaSearchPushRow.swift
//  RussianBills
//
//  Created by gotelgest
//  https://gist.github.com/gotelgest/cf309f6e2095ff22a20b09ba5c95be36
//
//  Modified by Xan Kraegor on 01.01.2018.
//  Copyright © 2018 Xan Kraegor. All rights reserved.
//

import Foundation
import Eureka

open class _SearchSelectorViewController<Row: SelectableRowType, OptionsRow: OptionsProviderRow>: SelectorViewController<OptionsRow>, UISearchResultsUpdating where Row.Cell.Value: SearchPushRowItem {

    let searchController = UISearchController(searchResultsController: nil)
    var originalOptions = [ListCheckRow<Row.Cell.Value>]()
    var currentOptions = [ListCheckRow<Row.Cell.Value>]()

    open override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        let scb = searchController.searchBar
        scb.searchBarStyle = .default
        scb.barTintColor = UIColor.ztint

        if let textField = scb.value(forKey: "searchField") as? UITextField {
            textField.tintColor = UIColor.black
            if let backgroundView = textField.subviews.first {
                backgroundView.backgroundColor = UIColor.zSearchBarBackgroundColor
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
            }
        }

        if let allRows = form.first?.map({ $0 }) as? [ListCheckRow<Row.Cell.Value>] {
            originalOptions = allRows
            currentOptions = originalOptions
        }

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }

    public func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            return
        }
        if query.isEmpty {
            currentOptions = originalOptions
        } else {
            currentOptions = originalOptions.filter {
                $0.selectableValue?.matchesSearchQuery(query) ?? false
            }
        }
        tableView.reloadData()
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOptions.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = currentOptions[indexPath.row]
        option.updateCell()
        return option.baseCell
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentOptions[indexPath.row].didSelect()
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

open class SearchSelectorViewController<OptionsRow: OptionsProviderRow>: _SearchSelectorViewController<ListCheckRow<OptionsRow.OptionsProviderType.Option>, OptionsRow> where OptionsRow.OptionsProviderType.Option: SearchPushRowItem {
}

open class _SearchPushRow<Cell: CellType>: SelectorRow<Cell> where Cell: BaseCell, Cell.Value: SearchPushRowItem {

    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return SearchSelectorViewController<SelectorRow<Cell>> { _ in
            }
        }, onDismiss: { vc in
            let _ = vc.navigationController?.popViewController(animated: true)
        })
    }

}

public final class SearchPushRow<T: Equatable>: _SearchPushRow<PushSelectorCell<T>>, RowType where T: SearchPushRowItem {

    public required init(tag: String?) {
        super.init(tag: tag)
    }

}
