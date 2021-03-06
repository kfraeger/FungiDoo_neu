//
//  Question.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 13.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//
//  Model of Questions decodable from json

import Foundation
import UIKit

enum QuestionType : String, Decodable{
    case busch = "busch"
    case geruch = "geruch"
    case geruchRichtung = "geruchRichtung"
    case hutForm = "hutForm"
    case hutFarbe = "hutFarbe"
    case hutOberflaeche = "hutOberflaeche"
    case hutUnterseite = "hutUnterseite"
    case hutUnterseiteFarbe = "hutUnterseiteFarbe"
    case huVerfaerbung = "huVerfaerbung"
    case huVerfaerbungFarbe = "huVerfaerbungFarbe"
    case stielForm = "stielForm"
    case stielBasis = "stielBasis"
    case stielFarbe = "stielFarbe"
    case stielOberflaeche = "stielOberflaeche"
    case stielNetzFlockenFarbe = "stielNetzFlockenFarbe"
    case stielRing = "stielRing"
    case stielBasisVolva = "stielBasisVolva"
    case stielHohl = "stielHohl"
    case fleischFarbe = "fleischFarbe"
    case fleischVerfaerbung = "fleischVerfaerbung"
    case fleischVerfaerbungFarbe = "fleischVerfaerbungFarbe"
    
    
}
struct Question : Decodable {
    
    let questionType : QuestionType
    let questionText : String
    let questionImageURL : String
    let questionAnswer : String
    
    private enum CodingKeys : String, CodingKey {
        case questionType = "questionsType"
        case questionText = "text"
        case questionImageURL = "image"
        case questionAnswer = "answer"
    }
}

struct Questions : Decodable {
    let questions : [Question]
}

