//
//  GlossarDetailViewController.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 09.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import CoreData

class GlossarDetailVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var pilzData : PilzGlossar?
    var eatableIcon = String()
    
    let descriptionDetails = ["Hut", "Stiel", "Poren", "Lamellen", "Geruch", "Standort", "Synonym"]
    
    
    @IBOutlet weak var pilzImageView: UIImageView!
    @IBOutlet weak var eatableImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lateinNameLabel: UILabel!
    

    @IBOutlet weak var familyGroupLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    @IBOutlet weak var bottomContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = pilzData {
            
            pilzImageView.image = UIImage(named: data.imageURL!)
            eatableImageView.image = UIImage(named: eatableIcon)
            
            nameLabel.text = data.name
            lateinNameLabel.text = data.lateinName
            
            familyGroupLabel.text = data.family
            dateRangeLabel.text = data.dateRange
            
            createLabels(data: data, x: 25, y: 60)
            
        }
        
        
    }
    
    
    func createDescriptionLabel(data: PilzGlossar, and key: String, x: CGFloat, y: CGFloat) {
        
        let label = UILabel(frame: CGRect(x: x, y: y, width: view.frame.width - 50, height: 25))
        label.textAlignment = .left
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.text = "\(key):"
        
        let subLabel = UILabel()
        subLabel.textAlignment = .left
        subLabel.textColor = UIColor.gray
        subLabel.font = UIFont.systemFont(ofSize: 14.0)
        subLabel.numberOfLines = 0
        subLabel.lineBreakMode = .byWordWrapping
        
        subLabel.text = (data.value(forKeyPath: key.lowercased()) as! String)
        subLabel.sizeToFit()
        subLabel.frame = CGRect(x: label.frame.minX, y: label.frame.maxY, width: view.frame.width - 50, height: subLabel.frame.height)
        
        
        self.bottomContainerView.addSubview(label)
        self.bottomContainerView.addSubview(subLabel)
        
        
        
    }
    
    func createLabels(data: PilzGlossar, x: CGFloat, y: CGFloat){
        var yPos = 0

        for val in descriptionDetails {
            if data.value(forKey: val.lowercased()) != nil {
                createDescriptionLabel(data: data, and: val, x: x , y: y + 60 * CGFloat(yPos))
                yPos += 1
            }
        }
   
    }
    
    

}
