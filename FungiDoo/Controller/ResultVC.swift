//
//  ResultVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 18.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class ResultVC: UIViewController {
    
    var result = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var resultImageView: UIImageView!    
    @IBOutlet weak var resultTextLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if result != "" {
        
        resultImageView.image = UIImage(named: "noimage_icon")
        resultTextLabel.text = result
        } else {
            resultImageView.image = UIImage(named: "noimage_icon")
            resultTextLabel.text = "Keinen Eintrag gefunden"
        }
    }
    
    @IBAction func finishedButtonPressed(_ sender: UIButton) {
        print("finishedPressed")
        performSegue(withIdentifier: "unwindToStartVC", sender: sender)
    }
    
    

}
