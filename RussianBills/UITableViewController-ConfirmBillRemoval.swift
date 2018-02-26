//
//  UITableViewController-Ask.swift
//  RussianBills
//
//  Created by Xan Kraegor on 05.01.2018.
//  Copyright © 2018 Xan Kraegor. All rights reserved.
//

import UIKit

extension UITableViewController {
    func askToRemoveFavoriteBillWithNote(completionIfTrue: @escaping () -> Void) {
        let alert = UIAlertController(title: "При удалении из отслеживаемых заметка также будет удалена", message: "Подтверждаете удаление из отслеживаемого?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { (_) in
            completionIfTrue()
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
