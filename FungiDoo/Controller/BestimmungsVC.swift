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

    
    //all variables for entropy calculation
    var countedClasses = 0
    var propertyClass = "klasse"
    var propertyNameArray = [String]()
    var propertyCalculatet = ""
    
    var countedPropertyValue = Dictionary<String, Any>()
    var countedPropertyValuePerClass = Dictionary<String, Any>()
    
    var entropyClasses : Float = 0 //needed for calculation of information gain
    var bestInfoGainProperty = [String : Any]()
    var propertyNoCalculation = ["klasse"]
    
    //parsed CSV data from file
    let csvFilePilze = "Daten"
    //let csvFile = "test"
    let delimiterCSV = ";"
    var dataArrayCSV = [[String]]()
    
    //decode JSON data from file
    let jsonFile = "questions"
    var questions : Questions?
    var pickedAnswer : Bool = false
    var resultPicked = false
    var resultText = ""
    
    
    //MARK: - IBOutlets
    /***************************************************************/
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    
    
    //MARK: - life cycle
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearDatabase()
        readDataFromCSVFile(file: csvFilePilze)
        readJSONData(from: jsonFile)
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
        var check = ""
        var count = 0
        
        if sender.tag == 1 {
            pickedAnswer = true
            saveAnswersWithProperty(from: pickedAnswer)
        } else if sender.tag == 2 {
            pickedAnswer = false
            saveAnswersWithProperty(from: pickedAnswer)
        }
        
        for item in dataArray {
            if item.klasse != nil{
                let klasse = item.klasse
                if klasse != check {
                    print("klasse : \(String(describing: klasse)) ....... check \(check)" )
                    
                    check = klasse!
                    count += 1
                    print("count \(count)")
                }
            }
            
        }
        
        if count < 2 {
           
                print(resultPicked)
                resultPicked = true
                questionLabel.text = check
            questionImage.isHidden = true
           
        } else {
            nextQuestion()
            getQuestion(for: propertyCalculatet)
        }
        
    }
    
    
    //MARK: - methods for the question
    /***************************************************************/
    
    func getQuestion(for type : String){
       
        let property = type
        var resultQuestions = [Question]()
        
        print(property)
        
        if let allquestion = questions?.questions {
            for item in allquestion {
                if item.questionType.rawValue == property {
//                    print(item)
//                    print(item.questionText)
                    resultQuestions.append(item)
                }
            }
        }
        
        print("--------------resultQuestions-------------------------")
        print(resultQuestions)
        
        
        
        
        
            let randomQuestionIndex = getRandomIndexOfQuestion(from: resultQuestions)
                //gets an random question of the result of the questions and shows text and image
                    questionLabel.text = resultQuestions[randomQuestionIndex].questionText
                    questionImage.image = UIImage(named: resultQuestions[randomQuestionIndex].questionImageURL)
                    //stores the given answer related to the property
            tempPropertyQuestion = property
            tempAnswerQuestion = resultQuestions[randomQuestionIndex].questionAnswer.description
            
            
        
            
    
        
        
    
    }
    
    
    /**
     gets an random index number of the counted questions
     */
    func getRandomIndexOfQuestion(from resultArray : [Question]) -> Int{
        let number : UInt32 = UInt32(resultArray.count)
        return Int(arc4random_uniform(number))
    }
    
    
    
    /**
     updates all views on screen
     */
    func updateUI(){
        
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
        print("_____________________resultsArrayOfPickedAnswersOfProperty :\(resultsArrayOfPickedAnswersOfProperty)")
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
    
//    func identificationMethodsStart(){
//        countedClasses = getTotalOfClasses()
//        print("Kalkulation Entropy Klasse")
//        print(countClassValues(propertyKey : "klasse"))
//        entropyClasses = calcEntropyClass(dic: countClassValues(propertyKey : "klasse"))
//        print("---------- entropyClasses : \(entropyClasses)")
//
//        propertyCalculatet = getEntropyForAllProperties()
//
//    }
    
    func identificationMethods(){
        countedClasses = getTotalOfClasses()
        print("Kalkulation Entropy Klasse")
        print(countClassValues(propertyKey : "klasse"))
        entropyClasses = calcEntropyClass(dic: countClassValues(propertyKey : "klasse"))
        print("---------- entropyClasses : \(entropyClasses)")
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


    
    //MARK: - methods for JSON encoding
    /***************************************************************/
    
    /**
     reads JSON File from path
     - Parameters: String
     */
    func readJSONData(from file: String) {
        
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData : Data = try Data(contentsOf: url)
            questions = try! JSONDecoder().decode(Questions.self, from: jsonData)
            
            //print(questions!)
            
        }catch {
            print("json daten konnten nicht gelesen werden.")
        }
    }
    
    
    
    
    //MARK: - methods for CSV parsing and Core Data
    /***************************************************************/
    
    /**
     reads CSV File from path
     and calls the parseCSV method
     - Parameters: String
     */
    func readDataFromCSVFile(file: String) {
        //print(file)
        guard let path = Bundle.main.path(forResource: file, ofType: "csv") else {return}
        //print (path)
        let contentsOfURL = URL(fileURLWithPath: path)
        parseCSV(contentsOfURL: contentsOfURL, encoding: String.Encoding.macOSRoman)
    }
    
    
    /**
     parses data from CSV file to array
     calls the cleanArray method
     calls the removeHeaderOfColoum
     calls the createDataforDB
     - Parameters:
     - URL
     - String.Encoding
     */
    func parseCSV (contentsOfURL: URL, encoding: String.Encoding) {
        //print("parseCSV")
        
        do {
            let content = try String(contentsOf: contentsOfURL, encoding: encoding)
            let lines : [String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            
            for line in lines {
                var values:[String] = []
                values = line.components(separatedBy: delimiterCSV)
                values = cleanArray(data: values)
                
                if values != [""] && !values.isEmpty{
                    dataArrayCSV.append(values)
                }
            }
            
        } catch {
            print("die csv datei konnte nicht gelesen werden \(error)")
        }
        
        dataArrayCSV = removeHeaderOfColoumn(at: 0, array: dataArrayCSV)
        createDataForDB(array: dataArrayCSV)
    }
    
    
    /**
     removes empty coloumns from parsed Data
     - Parameters: array of Strings
     - Returns: array of Strings
     */
    func cleanArray(data : [ String ]) -> [String]{
        var arrayTemp = [String]()
        for item in data {
            if item != "" {
                arrayTemp.append(item)
            }
        }
        return arrayTemp
    }
    
    
    /**
     removes firtst row with the titles of the coloumns
     - Parameters:
     - Int: index of row
     - array of array with Strings
     - Returns: array of array with Strings
     */
    func removeHeaderOfColoumn(at index: Int, array: [[ String ]]) -> [[String]] {
        var arrayTemp = [[String]]()
        arrayTemp = array
        
        //save the table header keys
        for item in arrayTemp[index]{
            propertyNameArray.append(item)
        }
        //delete the first item with the table headers
        arrayTemp.remove(at: index)
        return arrayTemp
    }
    
    
    /**
     creates all object for core data and saves it to it
     - Parameters:
     - array of array with Strings
     */
    func createDataForDB(array: [[ String ]]){
        
        //print(array)
        for item in array {
            
            let newItem = Pilz(context: context)

            newItem.klasse = item[0]
            newItem.busch = item[1]
            newItem.hutForm = item[2]
            newItem.hutOberflaeche = item[3]
            newItem.hutUnterseite = item[4]
            newItem.hutUnterseiteFarbe = item[5]
            newItem.huVerfaerbung = item[6]
            newItem.huVerfaerbungFarbe = item[7]
            newItem.hutFarbe = item[8]
            newItem.stielForm = item[9]
            newItem.stielBasis = item[10]
            newItem.stielFarbe = item[11]
            newItem.stielOberflaeche = item[12]
            newItem.stielNetzFlockenFarbe = item[13]
            newItem.stielRing = item[14]
            newItem.stielBasisVolva = item[15]
            newItem.stielHohl = item[16]
            newItem.fleischFarbe = item[17]
            newItem.fleischVerfaerbung = item[18]
            newItem.fleischVerfaerbungFarbe = item[19]
            newItem.geruch = item[20]
            
            saveItem()
        }
        
    }
    
    /**
     saves context to core data
     */
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    /**
     loads all items from core data
     */
    func loadItems(){
        let request : NSFetchRequest<Pilz> = Pilz.fetchRequest()
        do {
            dataArray = try context.fetch(request)
            dataArray = dataArray.reversed()
            //print(dataArray)
        } catch {
            print("Error in fetching Items \(error)")
        }
    }
    
    /**
     deletes all items from core data
     */
    func clearDatabase(){
        let request : NSFetchRequest<Pilz> = Pilz.fetchRequest()
        
        do {
            dataArray = try context.fetch(request)
            for item in dataArray {
                context.delete(item)
                saveItem()
            }
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
        
        
    }
    
    

}
