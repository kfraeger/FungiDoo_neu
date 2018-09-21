//
//  UserListAddItemMapVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 21.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationChangeDelegate {
    
    func userChangedLocation(coordinate : CLLocationCoordinate2D)
    
}

class UserListAddItemMapVC: UIViewController {

    //MARK: - Instance Variables
    /***************************************************************/
    
    let locationManager = CLLocationManager()
    let regionInMeters : Double = 0.008
    var userLocation : CLLocation?
    private var gestureRecognizer = UITapGestureRecognizer()
    var annotationSet = false
    var annotationTemp = MKPointAnnotation()
    var coordinateTemp = CLLocationCoordinate2D()
    var delegate : LocationChangeDelegate?
    
    let okayButtonConstantHide : CGFloat = 0
    let okayButtonConstantShow : CGFloat = 55
    let animateDuration : Double = 0.3
    
    
    //MARK: - IBOutlets
    /***************************************************************/
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var postCodeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var okayButtonConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureOkayButton()
        checkLocationServicePermission()
        gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleMapTap(gesture:)));
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func configureOkayButton(){
        okayButton.isHidden = true
    }
    
    
    //hide and show datePicker animated
    private func animateOkayButton(duration : Double, constant : CGFloat, isHidden: Bool) {
        UIView.animate(withDuration: duration) {
            self.okayButton.isHidden = isHidden
            self.okayButtonConstraint.constant = constant
            self.view.layoutIfNeeded()
            self.view.snapshotView(afterScreenUpdates: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okayButtonPressed(_ sender: UIButton) {
        delegate?.userChangedLocation(coordinate : coordinateTemp)
        print("okayPressed")
        print(coordinateTemp.latitude.description)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - reverse Location placemarks from map tap coordinate
    /***************************************************************/
    
    @objc private func handleMapTap(gesture : UITapGestureRecognizer)  {
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        coordinateTemp = coordinate
        // Add annotation:
        
        if annotationSet {
            mapView.removeAnnotation(annotationTemp)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        annotationTemp = annotation
        annotationSet = true
        
        updateLabelFromMap(coordinate: coordinate)
        
        if okayButton.isHidden {
            animateOkayButton(duration: animateDuration, constant: okayButtonConstantShow, isHidden: false)
        }
    }
    
    private func updateLabelFromMap(coordinate : CLLocationCoordinate2D) {
        lonLabel.text = coordinate.longitude.description
        latLabel.text = coordinate.latitude.description
        lookUpMapLocation(coordinate: coordinate) { (placemark) in
            guard let placemark = placemark else {return}
            DispatchQueue.main.async {
                self.streetLabel.text = placemark.thoroughfare
                self.postCodeLabel.text = placemark.postalCode
                self.cityLabel.text = placemark.locality
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
    
    
    
    

    //MARK: - Location Methods
    /***************************************************************/
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationServicePermission(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            enableBasicLocationService()
        } else {
            
        }
    }
    
    func showUserLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, span: MKCoordinateSpan(latitudeDelta: regionInMeters, longitudeDelta: regionInMeters))
            mapView.setRegion(region, animated: true)
        }
    }
    
    func enableBasicLocationService(){
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            showUserLocation()
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            //show alert
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
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
        else {
            // No location was available.
            completionHandler(nil)
        }
    }

}

//MARK: - CLLocationManagerDelegate Methods
/***************************************************************/

extension UserListAddItemMapVC : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {return}
        
        
        
        if lastLocation.horizontalAccuracy > 0{
            
            locationManager.stopUpdatingLocation()
            //startTrackingUserLocation(lat: lastLocation.coordinate.latitude, lon: lastLocation.coordinate.longitude)
            
            let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, span: MKCoordinateSpan(latitudeDelta: regionInMeters, longitudeDelta: regionInMeters))
            mapView.setRegion(region, animated: true)
            
            self.lookUpCurrentLocation { (placemark) in
                guard let placemark = placemark else {return}
                DispatchQueue.main.async {
                    self.streetLabel.text = placemark.thoroughfare
                    self.postCodeLabel.text = placemark.postalCode
                    self.cityLabel.text = placemark.locality
                    self.latLabel.text = lastLocation.coordinate.latitude.description
                    self.lonLabel.text = lastLocation.coordinate.longitude.description
                }
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        enableBasicLocationService()
    }
    
}
