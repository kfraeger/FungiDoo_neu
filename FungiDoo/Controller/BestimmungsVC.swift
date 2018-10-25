//
//  BestimmungsVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 10.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import CoreData

class BestimmungsVC: UIViewController {
    
    
    //MARK: - var & let
    /***************************************************************/
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dataArray = [Pilz]()
    var tempPropertyQuestion = ""
    var tempAnswerQuestion = ""
    var resultsArrayOfPickedAnswersOfProperty = [[String: Any]]()
    var questionNumber = 0
    var resultKlasse = ""

    
    //all variables for entropy calculation
    var countedClasses = 0
    var propertyClass = "klasse"
    var propertyNameArray = ["klasse","busch", "hutForm", "hutOberflaeche", "hutUnterseite", "hutUnterseiteFarbe", "huVerfaerbung" , "huVerfaerbungFarbe" ,"hutFarbe", "stielForm", "stielBasis", "stielFarbe", "stielOberflaeche", "stielNetzFlockenFarbe", "stielRing", "stielBasisVolva", "stielHohl", "fleischFarbe", "fleischVerfaerbung", "fleischVerfaerbungFarbe", "geruch", "geruchRichtung"]
    var propertyCalculatet = ""
    
    var countedPropertyValue = Dictionary<String, Any>()
    var countedPropertyValuePerClass = Dictionary<String, Any>()
    
    var entropyClasses : Float = 0 //needed for calculation of information gain
    var bestInfoGainProperty = [String : Any]()
    var propertyNoCalculation = ["klasse"]
    
    //parsed CSV data from file
    let csvFilePilze = "Data"
    //let csvFile = "test"
    let delimiterCSV = ";"
    var dataArrayCSV = [[String]]()
    
    //decode JSON data from file
    //let jsonFile = "questions"
    //var questions : Questions?
    var questions : QuestionDB?
    var pickedAnswer : Bool = false
    var resultPicked = false
    var resultText = ""
    
    
    //MARK: - IBOutlets
    /***************************************************************/
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    
    
    //MARK: - life cycle
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        clearDatabase()
//        readDataFromCSVFile(file: csvFilePilze)
  //      readJSONData(from: jsonFile)
        loadItems()
        identificationMethods()
        //identificationMethodsStart()
        print("------- vorher kalkulationstuff ---------------------------------\n")
        print(propertyNameArray)
        getQuestion(for: propertyCalculatet)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        resultsArrayOfPickedAnswersOfProperty.removeAll()
    }
    
    @IBAction func answerPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            pickedAnswer = true
            saveAnswersWithProperty(from: pickedAnswer)
        } else if sender.tag == 2 {
            pickedAnswer = false
            saveAnswersWithProperty(from: pickedAnswer)
        }
        startOverCalculation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToResultVC"{
            let destinationVC = segue.destination as! ResultVC
            destinationVC.result = resultKlasse
        }
    }
    
    
    //MARK: - methods for the question
    /***************************************************************/
    
    func startOverCalculation() {
        var check = ""
        var count = 0
        
        print(questionNumber)
        
        
        if !dataArray.isEmpty {
            for item in dataArray {
                if item.klasse != nil{
                    let klasse = item.klasse
                    if klasse != check {
                        check = klasse!
                        
                        count += 1
                    }
                }
            }
            
            if count < 2 || questionNumber >= 20{
                
                print(resultPicked)
                resultPicked = true
                resultKlasse = check
                self.performSegue(withIdentifier: "goToResultVC", sender: self)
                
            } else {
                nextQuestion()
                getQuestion(for: propertyCalculatet)
                updateProgressView(number: dataArray.count)
            }
        
            questionNumber += 1
        } else {
            print("Es gibt keinen Eintrag mit dieser Kombination")
            self.performSegue(withIdentifier: "goToResultVC", sender: self)
            resultKlasse = ""
        }
    }
    
    func updateProgressView(number : Int){
        
        let progress : Float = 1 / Float(number)
        
        progressView.setProgress(progress, animated: true)
        progressView.progress = progress
        
    }
    
    
    
    func getQuestion(for type : String){
        print("+++++++++++++++++++++++++++++++++++++getQuestion++++++++++++++++++++++++++++++++++++++++")
        print(type)
        
        
        var resultQuestions = [QuestionDB]()
    
        let request : NSFetchRequest<QuestionDB> = QuestionDB.fetchRequest()
        request.predicate = NSPredicate(format: "questionType==%@", type)
        
        do {
            resultQuestions = try context.fetch(request)
            
        } catch {
            print("Error in fetching Items \(error)")
        }
        print("+++++++++++++++++++++++++++++++++++++fetchResults++++++++++++++++++++++++++++++++++++++++")
       
    
        print(resultQuestions.count)
        
        let randomQuestionIndex = getRandomIndexOfQuestion(from: resultQuestions)
        //gets an random question of the result of the questions and shows text and image
        questionLabel.text = resultQuestions[randomQuestionIndex].questionText
        questionImage.image = UIImage(named: resultQuestions[randomQuestionIndex].questionImageURL!)
        //stores the given answer related to the property
        tempPropertyQuestion = type
        tempAnswerQuestion = resultQuestions[randomQuestionIndex].questionAnswer!.description
        
    }
    
    
    /**
     gets an random index number of the counted questions
     */
    func getRandomIndexOfQuestion(from resultArray : [QuestionDB]) -> Int{
        let number : UInt32 = UInt32(resultArray.count)
        return Int(arc4random_uniform(number))
    }
    

    
    /**
     will update the question text
     */
    func nextQuestion(){
        identificationMethods()
    }
    
    /**
     proceed the bestimmung for the answers
     */
    func saveAnswersWithProperty(from buttonInput : Bool){
        var temp = [String : Any]()
 
        temp["property"] = tempPropertyQuestion
        temp["questionAnswer"] = tempAnswerQuestion
        temp["userAnswer"] = buttonInput
        
        resultsArrayOfPickedAnswersOfProperty.append(temp)
        //print(resultsArrayOfPickedAnswersOfProperty)
        getItemFromDB()
    }
    
    
    
    //MARK: - statistic calculations
    /***************************************************************/
    
    /**
     returns the total of counted pilz objects
     from data array
     - Returns: counted number as Int
     */
    func getTotalOfClasses() -> Int {
        return dataArray.count
    }
    
    func identificationMethods(){
        countedClasses = getTotalOfClasses()
        entropyClasses = calcEntropyClass(dic: countClassValues(propertyKey : "klasse"))
        calcEntropyPropertiesForQuestions()
        propertyCalculatet = getEntropyForAllProperties(without : propertyNoCalculation)
    }
    
    func calcEntropyPropertiesForQuestions() {
        print(resultsArrayOfPickedAnswersOfProperty)
        for item in resultsArrayOfPickedAnswersOfProperty {
            propertyNoCalculation.append(item["property"] as! String)
        }
        propertyCalculatet = getEntropyForProperties(without : propertyNoCalculation)
       
    }
    
    func getEntropyForProperties(without : [String]) -> String {
        var entropiesDic = Dictionary<String, Any>()
        var bestGain : Float = 0
        var propertyKey = ""
        
        for item in propertyNameArray {
            
            print("for item in propertyNameArray: \(item)")
    
            if !without.contains(item){
                print("item != klasse && !without.contains(item): \(item)")
                let dic = getClassesForPropertyAndCount(from: countPropertyValues(propertyKey: item), and: item)
                for (key, value) in dic {
                    let gainTemp = calcInformationGain(from: value)
                    print("key : \(key) ---------------------value : \(value) -------- gainTemp: \(gainTemp)")
                    
                    if bestGain < gainTemp {
                        bestGain = gainTemp
                        propertyKey = key
                        entropiesDic["property"] = propertyKey
                        entropiesDic["gain"] = bestGain
                    }
                }
            }
        }
        print(entropiesDic)
        return propertyKey
    }
    
    func getEntropyForAllProperties(without : [String]) -> String {
        var entropiesDic = Dictionary<String, Any>()
        var bestGain : Float = 0
        var propertyKey = ""
        
        for item in propertyNameArray {
             if !without.contains(item){
                let dic = getClassesForPropertyAndCount(from: countPropertyValues(propertyKey: item), and: item)
                for (key, value) in dic {
                    let gainTemp = calcInformationGain(from: value)
                    print("key : \(key) ---------------------value : \(value) -------- gainTemp: \(gainTemp)")
                    
                    if bestGain <= gainTemp {
                        bestGain = gainTemp
                        propertyKey = key
                        entropiesDic["property"] = propertyKey
                        entropiesDic["gain"] = bestGain
                    }
                }
            }
        }
        print(entropiesDic)
        return propertyKey
    }
    
    /**
     calculates the information gain of a property and
     returns the gain
     - Parameters: entropy of a property
     - Returns: calculatd gain
     */
    func calcInformationGain(from entropy : Float) -> Float{
        return entropyClasses - entropy
    }
    
    
    
    func countPropertyValues(propertyKey : String) -> Dictionary<String, Int> {
        var temp = [String]()
        
        for item in dataArray {
            let value = (item.value(forKey: propertyKey)) as! String
            temp.append(value)
            
        }
        let mappedItems = temp.map { ($0, 1) }
        let dic = Dictionary(mappedItems, uniquingKeysWith: +)
        
        return dic
        
    }
    
    func getClassesForPropertyAndCount(from dict : Dictionary<String, Int>, and propertyKey: String) -> Dictionary<String, Float>{
        var dic = Dictionary<String, Float>()
        var entroTotal : Float = 0
       
                for key in dict.keys {
                    let temp = getClassesForOnePropertyValue(from : key, and : propertyKey)
                    let mappedItems = temp.map { ($0, 1) }
                    let counts = Dictionary(mappedItems, uniquingKeysWith: +)
                    let entroTemp = calcEntropyClass(dic: counts)
                    let entropy = calcEntropyProperty(propertyEntropy: entroTemp, propertyTotal: temp.count, total: getTotalOfClasses())
                    entroTotal += entropy
                }
        dic[propertyKey] = entroTotal
        return dic
    }
    
    
    func calcEntropyProperty(propertyEntropy : Float, propertyTotal : Int, total : Int) -> Float{
        return Float(propertyTotal) / Float(total) * propertyEntropy
    }
    
    
    
    func countClassValues(propertyKey : String) -> Dictionary<String, Int>{
        var temp = [String]()
        
        for item in dataArray {
            let value = (item.value(forKey: propertyKey)) as! String
            temp.append(value)
            
        }
        let mappedItems = temp.map { ($0, 1) }
        let dic = Dictionary(mappedItems, uniquingKeysWith: +)
        
        return dic
    }
    
    
    func calcEntropyClass(dic : Dictionary<String, Int>) -> Float{
        let temp = dic
        var sum = 0
        var number : Float = 0
        
        for val in temp.values{
            sum += val
        }
        for val in temp.values {
            let x = Float(val)/Float(sum)
            number += -(x * log2(x))
            
        }
        return number
    }
    
    

    func getClassesForOnePropertyValue(from value : String, and key : String) -> [String]{
        var temp = [String]()
        var tempVal = ""

        for item in dataArray {
            tempVal = item.value(forKey: key) as! String
            if tempVal == value {
                temp.append((item.klasse?.description)!)
            }
        }
        return temp
    }

    
//    //MARK: - methods fetching data from core data
//    /***************************************************************/


    /**
     loads all items from core data
     */
    func loadItems(){
        let request : NSFetchRequest<Pilz> = Pilz.fetchRequest()
        do {
            dataArray = try context.fetch(request)
            //dataArray = dataArray.reversed()
            print(dataArray.count)
            print(dataArray)
        } catch {
            print("Error in fetching Items \(error)")
        }
    }
    
    
    /**
     get certain objects
     */
    func getItemFromDB(){
        var filter = ""
        var format = ""
        var compare = ""
        var predicate = [NSPredicate]()
        
        for item in resultsArrayOfPickedAnswersOfProperty{
            
            if let bool = item["userAnswer"] {
                if bool as! Bool == true {
                    compare = "=="
                    print("==")
                } else {
                    compare = "!="
                    print("!=")
                }
            }
            
            format = "\(item["property"]!) \(compare) %@"
            
            filter = "\(item["questionAnswer"]!)"
            print("format: \(format) ------------- filter :\(filter)")
            predicate.append(NSPredicate(format: format, filter))
        }
        
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: predicate)
        let request : NSFetchRequest<Pilz> = Pilz.fetchRequest()
        request.predicate = andPredicate
        
        do {
           dataArray = try context.fetch(request)
          
        } catch {
            print("Error in fetching Items \(error)")
        }
        print("+++++++++++++++++++++++++++++++++++++fetchResults++++++++++++++++++++++++++++++++++++++++")
        print(dataArray)
    }
    
    

}
