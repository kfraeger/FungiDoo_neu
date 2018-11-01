//
//  StartVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 18.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import CoreData

class StartVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard

    //parsed CSV data from file
    let csvFilePilze = "Data"
    let delimiterCSV = ";"
    let entityPilz = "Pilz"
    let userDefaultKeyCSV = "csvFileDate"
   
    
   //decode JSON data from file
    let jsonFile = "questions"
    var questions : Questions?
    let entityQuestionDB = "QuestionDB"
    let userDefaultKeyJSON = "jsonFileDate"
    
    //decode JSON data from file
    let jsonFileGlossar = "pilzeGlossar"
    var glossarItems : GlossarItems?
    let entityGlossarDB = "PilzGlossar"
    let userDefaultKeyGlossarJSON = "jsonFileDateGlossar"
    


    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfCSVModified(from: csvFilePilze, ofType: "csv", key: userDefaultKeyCSV)
        checkIfCSVModified(from: jsonFile, ofType: "json", key: userDefaultKeyJSON)
        checkIfCSVModified(from: jsonFileGlossar, ofType: "json", key: userDefaultKeyGlossarJSON)
    }
    
    @IBAction func unwindToStartVC(segue:UIStoryboardSegue) { }



    
    func checkIfCSVModified(from file: String, ofType: String, key : String){
        var dateVal = Date()
        
        guard let path = Bundle.main.path(forResource: file, ofType: ofType) else {return}
        
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                let modifiedDate = (attributes[FileAttributeKey.modificationDate] as? Date)!
                //
                if let value = defaults.object(forKey: key) as? Date {
                    print("valueexists :\(value)")
                    
                    dateVal = value
                } else {
                    print("valuedoesntexists )")
                    defaults.set(modifiedDate, forKey: key)
                }
                print("dateVal: \(dateVal)")
                print("creationDate: \(modifiedDate)")
                
                
                
                
                if dateVal != modifiedDate {
                    
                    print("dateVal < creationDate")
                    
                    if ofType == "csv" {
                        
                        clearDatabase(entityname: entityPilz)
                        readDataFromCSVFile(file: csvFilePilze)
                    } else if ofType == "json" {
                     
                        clearDatabase(entityname: entityQuestionDB)
                        clearDatabase(entityname: entityGlossarDB)
                        //readJSONData(from: jsonFile)
                        decodeQuestionToCoreData(file : jsonFile)
                        decodePilzGlossarToCoreData(file : jsonFileGlossar)
                        
                    }
                    
                     defaults.set(modifiedDate, forKey: key)
                }
            } catch let error as NSError {
                print("Probleme beim Lesen des Files: \(error)")
            }
    }
    
    
    
    //MARK: - methods for JSON encoding
    /***************************************************************/
    
    /**
     reads JSON File from path and decode to CoreData
     - Parameters: String
     */
    func decodePilzGlossarToCoreData(file : String){
        
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData : Data = try Data(contentsOf: url)
            glossarItems = try! JSONDecoder().decode(GlossarItems.self, from: jsonData)
            
            for item in (glossarItems?.glossarItems)! {
                let newItem = PilzGlossar(context: context)
                newItem.name = item.name
                newItem.lateinName = item.latein
                newItem.dateRange = item.dateRange
                newItem.family = item.family
                newItem.imageURL = item.imageURL
                newItem.eatable = item.essbar
                newItem.synonym = item.synonym
                newItem.hut = item.hut
                newItem.stiel = item.stiel
                newItem.poren = item.poren
                newItem.lamellen = item.lamellen
                newItem.fleisch = item.fleisch
                newItem.geruch = item.geruch
                newItem.standort = item.standort
                newItem.eatableIconString = updateEatableIcon(condition: item.essbar)
                saveItem()
            }
            
        }catch let error as NSError {
            print("Probleme beim Lesen der JSON-Datei: \(error).")
        }
        
    }
    
    //This method turns a condition code into the name of the eatable condition image
    private func updateEatableIcon(condition: String) -> String {
        
        switch (condition) {
            
        case "toedlich giftig":
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
    
    /**
     reads JSON File from path
     - Parameters: String
     */
    func decodeQuestionToCoreData(file : String){
        
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData : Data = try Data(contentsOf: url)
            questions = try! JSONDecoder().decode(Questions.self, from: jsonData)
            
            for item in (questions?.questions)! {
                let newItem = QuestionDB(context: context)
                newItem.questionType = item.questionType.rawValue
                newItem.questionText = item.questionText
                newItem.questionImageURL = item.questionImageURL
                newItem.questionAnswer = item.questionAnswer
                saveItem()
            }
            
        }catch let error as NSError {
            print("Probleme beim Lesen der JSON-Datei: \(error).")
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
         var dataArrayCSV = [[String]]()
 
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
        } catch let error as NSError {
            print("Probleme beim Lesen der CSV-Datei: \(error)")
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
            
            print(item)
            
            
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
            newItem.geruchRichtung = item[21]
            
            saveItem()
        }
        
    }
    
    /**
     saves context to core data
     */
    func saveItem() {
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving context \(error)")
        }
    }
    
    /**
     deletes all items from core data
     */
    func clearDatabase(entityname : String){
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityname)
        
        
        do {
            let dataArray = try context.fetch(request)
            for item in dataArray {
                context.delete(item as! NSManagedObject)
                saveItem()
            }
        } catch let error as NSError {
            print("Error in fetching Items \(error)")
        }
    }
    
}
