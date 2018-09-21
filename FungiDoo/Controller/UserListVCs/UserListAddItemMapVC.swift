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

class UserListAddItemMapVC: UIViewController {

    //MARK: - Instance Variables
    /***************************************************************/
    
    let locationManager = CLLocationManager()
    let regionInMeters : Double = 0.008
    var userLocation : CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServicePermission()
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
                    //self.streetLabel.text = placemark.thoroughfare
                    //self.postalCodeLabel.text = placemark.postalCode
                    //self.cityLabel.text = placemark.locality
                }
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        enableBasicLocationService()
    }
    
}
