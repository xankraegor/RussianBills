//
//  FavoritesTableViewCell.swift
//  RussianBills
//
//  Created by Xan Kraegor on 14.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

final class FavoritesTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var hasUpdatesLabel: UILabel?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    func configureView() {
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.contentView.layer.borderWidth = 5
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.groupTableViewBackground
    }
}
