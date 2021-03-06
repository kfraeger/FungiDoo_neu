//
//  UserListAddItemVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 18.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import CoreData

class UserListAddItemVC: UIViewController, CameraInputChangeDelegate, LocationChangeDelegate {
    
    private var authorizedSet = false
    //private let JSON_URL = "https://kfraeger.de/fungiDoo/pilzeList.json"
    private var gestureRecognizer = UITapGestureRecognizer()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tempData = [String : Any]()
    
    //textField
    var nameResult : String?
    var textFieldIsSet = false
    var nameList : [String] = Array()
    var filteredList : [String] = Array()
    var showResultRows = 0
    
    //date
    let placeHolderTextView = "Hier können Sie eigene Notizen hinterlegen."
    let datePickerConstantHide : CGFloat = 0
    let datePickerConstantShow : CGFloat = 150
    let animateDuration : Double = 0.3
    
    //location
    let locationManager = CLLocationManager()
    let regionInMeters : Double = 0.008
    var lastUserLocation = CLLocation()
    var coordinates = CLLocationCoordinate2D()
    var locationString = ""
    
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
    
    //searchResults for textField
    @IBOutlet weak var searchResultTable: UITableView!
    
    //image
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    //date
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    
   //location
    @IBOutlet weak var locationLabel: UILabel!
    
    
    //textView
    @IBOutlet weak var userNotesTextView: UITextView!
    @IBOutlet weak var textViewContainerTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInputTextField()
        getItemsNameFromDB()
        
        //getNameListDateFromJSON(url: JSON_URL)
        configureTableView()
        configureImageView()
        configureDateView()
        configureTextView()
        checkLibraryAuthStatus()
        checkLocationServicePermission()
        checkLocationAuthStatus()
        gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
        tempData["notes"] = ""
        
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
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        print(tempData)
        
        let newItem = UserItem(context: context)
        newItem.name = (tempData["name"] as! String)
        newItem.date = (tempData["date"] as! String)
        newItem.location = (tempData["location"] as! String)
        newItem.latitude = (tempData["lat"] as! String)
        newItem.longitude = (tempData["lon"] as! String)
        newItem.notes = (tempData["notes"] as! String)
        newItem.image = (tempData["image"] as! Data)
        saveItem()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        //dismiss(animated: true, completion: nil )
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    func saveItem() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        
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
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.clearsOnBeginEditing = true
        
        if let name = nameResult {
            if name != "Keinen Eintrag gefunden" {
                nameTextField.text = name
                tempData["name"] = name
                
            }
            textFieldIsSet = true
            
        }
        
        
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        if nameTextField.text?.isEmpty == true {
            searchResultTable.isHidden = true
            nameTextField.resignFirstResponder()
            textFieldIsSet = false
        } else {
            searchResultTable.isHidden = false
            filteredList = nameList.filter { $0.lowercased().contains(nameTextField.text!.lowercased()) }
            textFieldIsSet = true
            tempData["name"] = nameTextField.text
            searchResultTable.reloadData()
        }
        
    }
    
    @IBAction func textFieldDidEndOnExit(_ sender: UITextField) {
        nameTextField.resignFirstResponder()
        searchResultTable.isHidden = true
        checkIfImageAndNameSet()
    }
    
    //MARK: - searchTableView configure method
    /***************************************************************/
   
    private func configureTableView(){
        searchResultTable.delegate = self
        searchResultTable.dataSource = self
        searchResultTable.isHidden = true
    }
    
    
    //MARK: - get currend Date & datePickerChanged methods
    /***************************************************************/
    
    private func configureDateView() {
        datePicker.isHidden = true
        dateLabel.text = getCurrentDateTime()
        tempData["date"] = dateLabel.text
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
        tempData["date"] = dateLabel.text
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
        tempData["image"] = avatarImageView.image?.jpegData(compressionQuality: 0.5)
        imageIsSet = true
        checkIfImageAndNameSet()
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCameraVC" {
            let destinationVC = segue.destination as! CameraVC
            destinationVC.delegate = self
        } else if segue.identifier == "goToMapEditVC" {
            let destinationVC = segue.destination as! UserListAddItemMapVC
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
    
    func userChangedLocation(coordinate: CLLocationCoordinate2D) {
        updateLabelFromMap(coordinate: coordinate)
    }
    
    private func updateLabelFromMap(coordinate : CLLocationCoordinate2D) {
        lookUpMapLocation(coordinate: coordinate) { (placemark) in
            guard let placemark = placemark else {return}
            DispatchQueue.main.async {
                self.coordinates = placemark.location!.coordinate
                self.locationLabel.text = ("\(placemark.thoroughfare ?? "")\n\(placemark.postalCode ?? "") \(placemark.locality ?? "")")
                self.tempData["location"] = self.locationLabel.text
                self.tempData["lat"] = self.coordinates.latitude.description
                self.tempData["lon"] = self.coordinates.longitude.description
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func lookUpMapLocation(coordinate : CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        let lastLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    
}

//MARK: - Extension - UIImagePicker Delegate Methods
/***************************************************************/

extension UserListAddItemVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //didFinishPicking ImagePicker Method
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        avatarImageView.contentMode = .scaleAspectFit
        
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
            
        } else if let cropImage = info[UIImagePickerController.InfoKey.cropRect] as? UIImage{
            selectedImageFromPicker = cropImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            avatarImageView.image = selectedImage
            imageIsSet = true
            tempData["image"] = avatarImageView.image?.jpegData(compressionQuality: 0.5)
            checkIfImageAndNameSet()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //cancel Method of ImagePicker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Extension TableView Delegate Methods
/***************************************************************/

extension UserListAddItemVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        cell.textLabel?.text = filteredList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameTextField.text = filteredList[indexPath.row]
        tempData["name"] = nameTextField.text
        searchResultTable.isHidden = true
        self.nameTextField.endEditing(true)
        filteredList = []
    }
    
}

//MARK: - Network JSON Parsing & Fill NameList with data
/***************************************************************/
extension UserListAddItemVC {
    
    
    /**
     get certain objects
     */
    func getItemsNameFromDB()  {
        
        let request : NSFetchRequest<PilzGlossar> = PilzGlossar.fetchRequest()
        
        do {
            let items = try context.fetch(request)
            
            for item in items {
                nameList.append(item.name!)
                
            }
            
            nameList.sort()
            
        } catch {
            print("Error in fetching Items \(error)")
        }
    }
}

//MARK: - LocationManager methods delegate
/***************************************************************/

extension UserListAddItemVC: CLLocationManagerDelegate {
    
    private func checkLocationServicePermission(){
        print("checkLocationServicePermission()")
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            print("checkLocationServicePermission() if")
        } else {
            print("checkLocationServicePermission() else")
            checkLocationAuthStatus()
        }
    }
    
    func setupLocationManager() {
        print("setupLocationManager()")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func checkLocationAuthStatus(){
        print("enableBasicLocationService()")
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            print("authorized location")
        case .denied, .restricted:
            //show alert
            print("denied")
            AlertService.showGPSPermissionAlert(on: self)
        case .notDetermined:
            print("notDetermined")
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    private func lookUpCurrentLocation(lastLocation: CLLocation, completionHandler: @escaping (CLPlacemark?) -> Void ) {
        print("lookUpCurrenLocaton")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        print("didUpdateLocations")
        
        if lastLocation.horizontalAccuracy > 0{
            print("lastlocation.horizontal")
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            self.lookUpCurrentLocation(lastLocation: lastLocation){(placemark ) in
                guard let placemark = placemark else {return}
                
                DispatchQueue.main.async {
                    self.coordinates = placemark.location!.coordinate
                    self.locationLabel.text = ("\(placemark.thoroughfare ?? "")\n\(placemark.postalCode ?? "") \(placemark.locality ?? "")")
                    self.tempData["location"] = self.locationLabel.text
                    self.tempData["lat"] = self.coordinates.latitude.description
                    self.tempData["lon"] = self.coordinates.longitude.description
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationString = "Keine Ortung möglich."
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
            self.textViewContainerTopConstraint.constant = -150
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
            self.tempData["notes"] = placeHolderTextView
            textView.textColor = UIColor.lightGray
        }
        UIView.animate(withDuration: 0.3) {
            self.textViewContainerTopConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.view.snapshotView(afterScreenUpdates: true)
        }
        print(textView.text)
        tempData["notes"] = textView.text
    }
}


