//
//  GlossarHelpTableViewCell.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 13.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class GlossarHelpTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var iconHelpTextLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
