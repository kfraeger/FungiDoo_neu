//
//  ResultVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 18.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import CoreData

class ResultVC: UIViewController {
    
    var result = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var imageName = ""
    var pilzData : PilzGlossar?
    
    
    @IBOutlet weak var resultImageView: UIImageView!    
    @IBOutlet weak var resultTextLabel: UILabel!
    @IBOutlet weak var eatableImageView: UIImageView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if result != "" {
            getItemFromDB(name: result)
            
            if let data = pilzData {
                resultImageView.image = UIImage(named: data.imageURL!)
                resultTextLabel.text = data.name
                eatableImageView.image = UIImage(named: data.eatableIconString!)
            }
            
            
        } else {
            resultImageView.image = UIImage(named: "noimage_icon")
            resultTextLabel.text = "Keinen Eintrag gefunden"
            disable(button: saveButton)
            disable(button: detailButton)
            
        }
    }
    
    @IBAction func finishedButtonPressed(_ sender: UIButton) {
        print("finishedPressed")
        performSegue(withIdentifier: "unwindToStartVC", sender: sender)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserAddList" {
            let destinationVC = segue.destination as! UINavigationController
            if let childDestination  = destinationVC.topViewController as? UserListAddItemVC {
                childDestination.nameResult = result
                
            }
        } else if segue.identifier == "goToGlossarDetailResult"{
            let destinationVC = segue.destination as! GlossarDetailVC
            
            destinationVC.pilzData = pilzData
            
        }
    }
    
    /**
     changes color, alpha of button and
     disables it
     */
    func disable(button : UIButton){
        button.isEnabled = false
        button.backgroundColor = UIColor.lightGray
        button.alpha = 0.3
    }
    
    /**
     get certain object with name from PilzGlossar core data
     */
    func getItemFromDB(name : String) {
        
        let request : NSFetchRequest<PilzGlossar> = PilzGlossar.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let item = try context.fetch(request)
                pilzData = item[0]
        } catch {
            print("Error in fetching Items \(error)")
        }
    }
}
