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
    
    
    @IBOutlet weak var resultImageView: UIImageView!    
    @IBOutlet weak var resultTextLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if result != "" {
        imageName = getImageItemFromDB(name: result)
        resultImageView.image = UIImage(named: imageName)
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
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserAddList" {
            let destinationVC = segue.destination as! UINavigationController
            if let childDestination  = destinationVC.topViewController as? UserListAddItemVC {
                childDestination.nameResult = result
                
            }
        }
    }
    
    /**
     get certain objects
     */
    func getImageItemFromDB(name : String) -> String {
        
        let request : NSFetchRequest<PilzGlossar> = PilzGlossar.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let item = try context.fetch(request)
            
            if let imageUrl = item[0].imageURL {
                return imageUrl
            }
            
        } catch {
            print("Error in fetching Items \(error)")
        }
        
        return ""
    }

}
