//
//  QuickSearchTableViewCell.swift
//  RussianBills
//
//  Created by Xan Kraegor on 12.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

class QuickSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var billNumberLabel: UILabel!
    @IBOutlet weak var billNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
