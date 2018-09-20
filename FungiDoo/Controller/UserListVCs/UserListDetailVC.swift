//
//  UserListDetailVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 20.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit


class UserListDetailVC: UIViewController {
    
    
    var userData = UserItem(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        avatarImageView.image = UIImage(data: userData.image!)
        nameLabel.text = userData.name
        dateLabel.text = userData.date
        locationLabel.text = userData.location
        latitudeLabel.text = userData.latitude
        longitudeLabel.text = userData.longitude
        print("\(userData.latitude)")
        checkIfNotesSet()
        
    }
    

    func checkIfNotesSet() {
        if userData.notes != "" {
            notesTextView.text = userData.notes
        } else {
            notesTextView.text = "keine Notizen vorhanden"
        }
     
    }

}
