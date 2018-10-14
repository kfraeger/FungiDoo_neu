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
    
    //all variables for entropy calculation
    var countedClasses = 0
    var keyClass = "klasse"
    var keyArray = [String]()
    var entropyClasses : Float = 0 //needed for calculation of information gain
    var bestInfoGainProperty = [String : Float]()
    
    //parsed CSV data from file
    let csvFile = "Daten"
    let delimiterCSV = ";"
    var dataArrayCSV = [[String]]()
    
    //decode JSON data from file
    let jsonFile = "questions"
    
    
    //MARK: - IBOutlets
    /***************************************************************/
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    
    
    
    //MARK: - life cycle
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearDatabase()
        readDataFromCSVFile(file: csvFile)
        readJSONData(from: jsonFile)
        loadItems()
        countedClasses = getTotalOfClasses()
        print("-----------------------------------    gezählte Klassen für Kalkulation Entropie: \(countedClasses) ---------------")
        
        entropyClasses = calcEntropyOfClasses(for: keyClass, and: countedClasses)
        print("-----------------------------------    Entropie aller Klassen: \(entropyClasses) ---------------")
        
        
        bestInfoGainProperty = calcInformationGain(from: entropyClasses)
        print("-----------------------------------    bestInfoGainProperty ---------------")
        print(bestInfoGainProperty)
        
        
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func answerPressed(_ sender: Any) {
        
    }
    
    
    //MARK: - methods for the question
    /***************************************************************/
    
    /**
     updates all views on screen
     */
    func updateUI(){
        
    }
    
    /**
     will update the question text
     */
    func nextQuestion(){
        
    }
    
    /**
     proceed the bestimmung for the answers
     */
    func checkAnswer(){
        
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
    
    
    /**
     calculates the entropy of all identical classes
     from data array
     - Returns: Float
     */
    func calcEntropyOfClasses(for key : String, and counted: Int) -> Float{
        let classArray = countIdenticalRows(for: key)
        var entropyClasses :Float?
        
        entropyClasses = calcEntropy(of: classArray, total: counted)
        
        return entropyClasses ?? 0
    }
    
    
    /**
     calculates the entropy of all identical properties in
     relation to 'klasse'
     - Returns: array of property keys with the calculated entropy
     */
    func calcEntropyOfPropertiesOfClasses() -> [String : Float] {
        
        var propertyArray = [String : [String : Int]]()
        var entropyPropertyArray = [String : Float]()
        
        //for all properties except the 'klasse'
        for propertyKey in keyArray {
            if propertyKey != keyClass {
                propertyArray[propertyKey] = countIdenticalRows(for: propertyKey)
            }
        }
        
        print("------------------propertyArray-------------------------------------")
        print(propertyArray)
        
        
        for countedProperty in propertyArray {
            print(countedProperty)
            entropyPropertyArray[countedProperty.key] = calcEntropy(of: countedProperty.value, total: countedClasses)
            //entropyPropertyArray[countedProperty.key] = entropy
        }
        print("------------------entropyPropertyArray-------------------------------------")
        print(entropyPropertyArray)
        
        return entropyPropertyArray
    }
    
    
    /**
     calculates the information gain of all properties and
     returns best property to split information
     - Parameters: entropy of all classes
     - Returns: array of property key with the calculated gain
     */
    func calcInformationGain(from entropyClasses : Float) -> [String : Float]{
        var gain : Float = 0
        var keyProp = String()
        var bestGainProperty = [String : Float]()
        
        let entropiesPropertiesArray = calcEntropyOfPropertiesOfClasses()
        
        print("-----------------------------------    calcInformationGain() ---------------")
        
        for property in entropiesPropertiesArray {
            
            let gainTemp = entropyClasses - property.value
            print("property: \(property.key) gaintemp : \(gainTemp) gain: \(gain)\n")
            
            if gainTemp > gain {
                gain = gainTemp
                keyProp = property.key
            }
        }
        
        bestGainProperty[keyProp] = gain
        
        
        return bestGainProperty
    }
    
    
    /**
     calculates the entropy in relation to 'klasse' property of data
     - Parameters:
     - array:  String: contains the key of property Int: total counted number of the property
     - total:  number of rows of 'klasse' property
     - Returns: Float
     */
    func calcEntropy(of array : [String : Int], total : Int) -> Float{
        var number : Float = 0
        let total = Float(total)
        
        for klasse in array {
            let x = Float(klasse.value)/total
            number += -(x * log2(x))
            //print("klasse: \(klasse) entropy:  \(number)")
        }
        //print(number)
        return number
    }
    
    
    
    
    /**
     counts the identical rows of property and
     returns a array with the counted value and the number of it
     - Parameters: String:  key of property
     - Returns: [String : Int]
     */
    func countIdenticalRows(for key : String) -> [String : Int]{
        
        var identicalRowsArray = [String : Int]()
        var counter = 0
        //let totalNumbers = counted
        for item in dataArray {
            
            //print(item.value(forKeyPath: key))
            
            let val = item.value(forKeyPath: key) as! String
            
            if !identicalRowsArray.keys.contains(val){
                counter = 0
                identicalRowsArray[val] = counter + 1
            } else {
                counter = identicalRowsArray[val]!
                counter = counter + 1
                identicalRowsArray.updateValue(counter, forKey: val)
            }
        }
        return identicalRowsArray
    }
    
    
    //MARK: - methods for JSON encoding
    /***************************************************************/
    
    func readJSONData(from file: String){
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData : Data = try Data(contentsOf: url)
            let questions = try! JSONDecoder().decode(Questions.self, from: jsonData)
            
            print(questions)
            
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
        print("parseCSV")
        
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
            keyArray.append(item)
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

}
