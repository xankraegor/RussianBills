//
//  CommiteeTableViewCell.swift
//  RussianBills
//
//  Created by Xan Kraegor on 08.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class NameStartEndTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var beginDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!

    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
