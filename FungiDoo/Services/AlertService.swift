//
//  AlertService.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 17.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import Foundation
import UIKit

struct AlertService {
    
    
    static func showErrorConnectionAlert(on vc : UIViewController){
        let alert = UIAlertController(title: "Es ist ein Problem aufgetreten.", message: "Es konnten keine Daten geladen werden.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    static func showErrorCoreDataLoadAlert(on vc : UIViewController){
        let alert = UIAlertController(title: "Es ist ein internes Problem aufgetreten.", message: "Ihre Daten konnten nicht geladen werden.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    
    
    //Photo Library Asking for Permission Alert
    static func showFotosPermissionAlert(on vc : UIViewController){
        let alert = UIAlertController(title: "Bitte gestatte den Zugriff auf Fotos.", message: "So kannst du Fotos aufnehmen und speichern", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Einstellungen", style: .default) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    //GPS for Permission Alert
    static func showGPSPermissionAlert(on vc : UIViewController){
        let alert = UIAlertController(title: "Bitte gestatte den Zugriff auf deinen Standort.", message: "So können wir zu deinem Fund einen aktuellen Standort ermitteln.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Einstellungen", style: .default) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
