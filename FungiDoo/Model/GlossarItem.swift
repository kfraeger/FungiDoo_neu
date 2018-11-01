//
//  PilzeGlossar.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 17.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

struct GlossarItem : Decodable{
    
    
    let name : String
    let latein : String
    let dateRange : String
    let family : String
    let imageURL : String
    let essbar : String
    let synonym : String
    
    let hut: String
    let stiel : String
    let poren : String?
    var lamellen : String?
    let fleisch : String
    let geruch : String
    let standort : String
    
    private enum GlossarKeys : String, CodingKey {
        case name
        case latein
        case dateRange = "date_range"
        case family
        case imageURL
        case essbar
        case synonym
        case beschreibung
    }
    
    private enum DescriptionKeys : String, CodingKey {
        case hut = "Hut"
        case stiel = "Stiel"
        case lamellen = "Lamellen"
        case poren = "Poren"
        case fleisch = "Fleisch"
        case geruch = "Geruch"
        case standort = "Standort"
    }
    
    init(from decoder: Decoder) throws {
        let glossarContainer = try decoder.container(keyedBy: GlossarKeys.self)
        self.name = try glossarContainer.decode(String.self, forKey: .name)
        self.latein = try glossarContainer.decode(String.self, forKey: .latein)
        self.dateRange = try glossarContainer.decode(String.self, forKey: .dateRange)
        self.family = try glossarContainer.decode(String.self, forKey: .family)
        self.imageURL = try glossarContainer.decode(String.self, forKey: .imageURL)
        self.essbar = try glossarContainer.decode(String.self, forKey: .essbar)
        self.synonym = try glossarContainer.decode(String.self, forKey: .synonym)
        
        let descriptionContainer = try glossarContainer.nestedContainer(keyedBy: DescriptionKeys.self, forKey: .beschreibung)
        
        self.hut = try descriptionContainer.decode(String.self, forKey: .hut)
        
        self.lamellen = (descriptionContainer.contains(.lamellen)) ? try descriptionContainer.decodeIfPresent(String.self, forKey: .lamellen) : nil
        self.poren = (descriptionContainer.contains(.poren)) ? try descriptionContainer.decodeIfPresent(String.self, forKey: .poren) : nil
      
        
        self.stiel = try descriptionContainer.decode(String.self, forKey: .stiel)
        self.geruch = try descriptionContainer.decode(String.self, forKey: .geruch)
        self.standort = try descriptionContainer.decode(String.self, forKey: .standort)
        self.fleisch = try descriptionContainer.decode(String.self, forKey: .fleisch)
    }
    
}

struct GlossarItems : Decodable {
    let glossarItems : [GlossarItem]
}
