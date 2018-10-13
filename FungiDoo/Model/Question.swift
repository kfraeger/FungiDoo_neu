//
//  Question.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 13.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import Foundation
import UIKit

class Question {
    
    let questionText: String
    let questionImage : UIImage
    let questionAnswer : Bool
    
    init(text: String, image : UIImage, answer: Bool){
        questionText = text
        questionImage = image
        questionAnswer = answer
    }
}

