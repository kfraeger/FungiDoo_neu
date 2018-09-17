//
//  GlossarListTableViewCell.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 17.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class GlossarListTableViewCell: UITableViewCell {

    @IBOutlet weak var glossarImageView: UIImageView!
    @IBOutlet weak var glossarEatableImaveView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lateinNameLabel: UILabel!
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        DispatchQueue.main.async {
            self.glossarImageView.layer.cornerRadius = 10
            self.glossarImageView.layer.masksToBounds = true
        }
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
