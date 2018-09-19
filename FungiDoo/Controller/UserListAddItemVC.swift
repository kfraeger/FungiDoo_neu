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

    //date
    let placeHolderTextView = "Hier können Sie eigene Notizen hinterlegen."
    let datePickerConstantHide : CGFloat = 0
    let datePickerConstantShow : CGFloat = 150
    let animateDuration : Double = 0.3
    
    //image
    let cornerRadius :CGFloat = 8
    
    
    var gestureRecognizer = UITapGestureRecognizer()
    
    
    //Outlets
    /***************************************************************/
    
    //container views
    @IBOutlet weak var addImageContainerView: UIView!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var locationContainerView: UIView!
    
    //date
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //image
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImageView()
        configureDateView()
        
        gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
        
    }
    
    
    @objc private func backgroundTap(gesture : UITapGestureRecognizer) {
        //print("tap")
        if datePicker.isHidden == false {
            view.removeGestureRecognizer(gestureRecognizer)
            animateDatePicker(datePicker: datePicker, duration: animateDuration, constant: datePickerConstantHide, isHidden: true)
        }
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - get currend Date & datePickerChanged methods
    /***************************************************************/
    
    private func configureDateView() {
        datePicker.isHidden = true
        dateLabel.text = getCurrentDateTime()
    }
    
    private func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        return dateFormatter.string(from: Date())
    }

    //hide and show datePicker animated
    private func animateDatePicker(datePicker: UIDatePicker, duration : Double, constant : CGFloat, isHidden: Bool) {
        UIView.animate(withDuration: duration) {
            self.datePicker.isHidden = isHidden
            self.datePickerHeight.constant = constant
            self.view.layoutIfNeeded()
            self.view.snapshotView(afterScreenUpdates: true)
            
            
        }
    }

    @IBAction func datePickerChangedValue(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateLabel.text = dateFormatter.string(from: datePicker.date)
        self.view.layoutIfNeeded()
        view.endEditing(true)
    }
    
    @IBAction func editDateButtonPressed(_ sender: UIButton) {
        
        if datePicker.isHidden {
            animateDatePicker(datePicker: datePicker, duration: animateDuration, constant: datePickerConstantShow, isHidden: false)
            view.addGestureRecognizer(gestureRecognizer)
        } else {
            animateDatePicker(datePicker: datePicker, duration: animateDuration, constant: datePickerConstantHide, isHidden: true)
            view.removeGestureRecognizer(gestureRecognizer)
        }
    }
    
    
    //MARK: - addImage methods
    /***************************************************************/
    
    private func configureImageView() {
        avatarImageView.layer.cornerRadius = cornerRadius
        avatarImageView.clipsToBounds = true
    }
    
    
    
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    }
    
    
    
    
    
}

