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

class UserListAddItemVC: UIViewController, CameraInputChangeDelegate {
    
    private var authorizedSet = false
    private let JSON_URL = "https://kfraeger.de/fungiDoo/pilzeList.json"
    private var gestureRecognizer = UITapGestureRecognizer()
    
    //textField
    var textFieldIsSet = false
    var nameList : [String] = Array()
    var filteredList : [String] = Array()
    var showResultRows = 0
    
    //date
    let placeHolderTextView = "Hier können Sie eigene Notizen hinterlegen."
    let datePickerConstantHide : CGFloat = 0
    let datePickerConstantShow : CGFloat = 150
    let animateDuration : Double = 0.3
    
    //image
    let cornerRadius :CGFloat = 8
    var imageIsSet = false
    
    
    
    
    //Outlets
    /***************************************************************/
    
    //container views
    @IBOutlet weak var addImageContainerView: UIView!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var locationContainerView: UIView!
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //textfield
    @IBOutlet weak var nameTextField: UITextField!
    
    
    //date
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //image
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //textView
    @IBOutlet weak var userNotesTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInputTextField()
        getNameListDateFromJSON(url: JSON_URL)
        configureImageView()
        configureDateView()
        configureTextView()
        checkLibraryAuthStatus()
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
    
    //enables done Button of navigationbar
    func checkIfImageAndNameSet() {
        if textFieldIsSet && imageIsSet {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    //MARK: - textField methods
    /***************************************************************/
    func configureInputTextField() {
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameTextField.frame.height))
        nameTextField.leftViewMode = .always
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        if nameTextField.text?.isEmpty == true {
            //searchResultTableView.isHidden = true
            nameTextField.resignFirstResponder()
            textFieldIsSet = false
        } else {
            //searchResultTableView.isHidden = false
            filteredList = nameList.filter { $0.lowercased().contains(nameTextField.text!.lowercased()) }
            textFieldIsSet = true
            //searchResultTableView.reloadData()
        }
        
    }
    
    @IBAction func textFieldDidEndOnExit(_ sender: UITextField) {
        nameTextField.resignFirstResponder()
        //searchResultTableView.isHidden = true
        checkIfImageAndNameSet()
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
    
    //MARK: - alle user image methods -
    /***************************************************************/
    private func configureImageView() {
        avatarImageView.layer.cornerRadius = cornerRadius
        avatarImageView.clipsToBounds = true
    }
    
    func showCameraPicker() {
        print("kamera ausgewählt")
        self.performSegue(withIdentifier: "goToCameraVC", sender: self)
    }
    
    //opens ImagePickerController when permission is authorized
    func showImagePicker() {
        if authorizedSet {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            pickerController.allowsEditing = true
            pickerController.modalPresentationStyle = .overCurrentContext
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        showCameraPicker()
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        showImagePicker()
    }
    
    //MARK: - PHPhotoLibrary.authorizationStatus
    /***************************************************************/
    
    func checkLibraryAuthStatus(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        print("checkAuthStatus")
        switch photoAuthorizationStatus {
            
        case .authorized:
            // Access is granted by user.
            print("authorized")
            authorizedSet = true
            
        case .notDetermined:
            // It is not determined until now.
            
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.authorizedSet = true
                } else {}
                print("notDetermined")
                
            })
            
        case .restricted, .denied:
            // User do not have access to photo album.
            print("restricted")
            AlertService.showFotosPermissionAlert(on: self)
        }
    }
    
    //MARK: - Camera Input Changed Delegate methods
    /***************************************************************/
    
    func userTookANewPhoto(image: UIImage) {
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.image = image
       
        imageIsSet = true
        //checkIfImageAndNameSet()
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCameraVC" {
            let destinationVC = segue.destination as! CameraVC
            destinationVC.delegate = self
        }
       
    }
    
    //MARK: - textView
    /***************************************************************/
    private func configureTextView() {
        userNotesTextView.delegate = self
        userNotesTextView.text = placeHolderTextView
        userNotesTextView.textColor = UIColor.lightGray
    }
    
}

//MARK: - Extension - UIImagePicker Delegate Methods
/***************************************************************/

extension UserListAddItemVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //didFinishPicking ImagePicker Method
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        //print(info)
        
        avatarImageView.contentMode = .scaleAspectFit
        
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
            
        } else if let cropImage = info[UIImagePickerController.InfoKey.cropRect] as? UIImage{
            selectedImageFromPicker = cropImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            print("selectedImage")
            avatarImageView.image = selectedImage
            imageIsSet = true
            checkIfImageAndNameSet()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //cancel Method of ImagePicker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("ImagePicker canceled")
        dismiss(animated: true, completion: nil)
    }
}



//MARK: - Network JSON Parsing & Fill NameList with data
/***************************************************************/
extension UserListAddItemVC {
    
    func getNameListDateFromJSON(url : String) {
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess{
                print("Success! Daten erhalten")
                let dataJSON : JSON = JSON(response.result.value!)
                self.updateNameList(json: dataJSON)
                
            } else {
                print("Error : \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateNameList(json : JSON){
        if let tempResult = json["pilze"].array {
            print("tempResult updatePilzeData: \(tempResult.count)")
            
            for item in 0 ... tempResult.count - 1 {
                nameList.append(json[item]["name"].stringValue)
                nameList = nameList.sorted()
            }
        }
    }
}

//MARK: - UITextViewDelegate
/***************************************************************/

extension UserListAddItemVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        UIView.animate(withDuration: 0.3) {
            //self.middleView.isHidden = true
            //self.heightConstraintTableView.constant = 0
            self.view.layoutIfNeeded()
            self.view.snapshotView(afterScreenUpdates: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderTextView
            textView.textColor = UIColor.lightGray
        }
        UIView.animate(withDuration: 0.3) {
            //self.middleView.isHidden = false
            //self.heightConstraintTableView.constant = CGFloat(self.rowHeight * 2)
            self.view.layoutIfNeeded()
            self.view.snapshotView(afterScreenUpdates: true)
        }
    }
}


