//
//  GlossarDetailViewController.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 09.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class GlossarDetailVC: UIViewController {
    
    var pilzData = Pilze()
    
    @IBOutlet weak var pilzImageView: UIImageView!
    @IBOutlet weak var eatableImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lateinNameLabel: UILabel!
    

    @IBOutlet weak var familyGroupLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pilzImageView.image = pilzData.image
        eatableImageView.image = UIImage(named: pilzData.updateEatableIcon(condition: pilzData.essbar))
        
        nameLabel.text = pilzData.name
        lateinNameLabel.text = pilzData.latein
        
        familyGroupLabel.text = pilzData.family
        dateRangeLabel.text = pilzData.dateRange
        
    }

}
