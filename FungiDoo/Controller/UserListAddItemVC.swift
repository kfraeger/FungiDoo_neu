//
//  UserListAddItemVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 18.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import SwiftyJSON

class UserListAddItemVC: UIViewController {

    
    
    //Outlets
    /***************************************************************/
    
    @IBOutlet weak var addNameTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNotesTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func changeDateButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func editLocationButtonPressed(_ sender: UIButton) {
    }
    
}
