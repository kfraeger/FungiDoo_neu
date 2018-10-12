//
//  Pilze.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 17.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class PilzGlossar {
    
    var id : Int = 0
    var name : String = ""
    var latein : String = ""
    var dateRange : String = ""
    var family : String = ""
    var beschreibung : String = ""
    var imageURL : String = ""
    var essbar : String = ""
    var image : UIImage = UIImage(named: "noimage_icon")!
    var eatableIconString : String = ""
    
    
    //This method turns a condition code into the name of the eatable condition image
    func updateEatableIcon(condition: String) -> String {
        
        switch (condition) {
            
        case "tödlich giftig":
            return "giftig-toedlich-icon"
            
        case "giftig":
            return "giftig-icon"
            
        case "ungenießbar":
            return "ungeniessbar-icon"
            
        case "eingeschrenkt essbar":
            return "beschraenkt-essbar-icon"
            
        case "essbar":
            return "essbar-icon"
        default :
            return "noimage_icon"
        }
        
    }
    
    
}
