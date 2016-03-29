//
//  TableViewCell.swift
//  Rant N' Rave
//
//  Created by Gabe Wilson on 1/9/16.
//  Copyright © 2016 Gabe Wilson. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
