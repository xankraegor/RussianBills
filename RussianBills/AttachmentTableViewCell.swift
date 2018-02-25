//
//  AttachmentTableViewCell.swift
//  RussianBills
//
//  Created by Xan Kraegor on 28.10.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class AttachmentTableViewCell: UITableViewCell {

    @IBOutlet weak var docTypeImage: UIImageView?
    @IBOutlet weak var billTitle: UILabel?
    @IBOutlet weak var infoLabel: UILabel?


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
