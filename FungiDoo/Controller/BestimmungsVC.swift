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
   
    let csvFile = "Daten"
    let delimiterCSV = ";"
    
    //all variables for entropy calculation
    var countedClasses = 0
    var keyClass = "klasse"
    var entropyClasses : Float = 0 //needed for calculation of information gain
    var bestInfoGainProperty = [String : Float]()
    
    
    var dataArrayTemp = [Any]()
    var dataDict = [[String : String]]()
    var arrayKeyEntropies = [String : Float]()
    var keyArray = [String]()
    var totalNumberOfClasses  = 0
   
    
    var dataArrayCSVHeader = [String]()
    var dataArrayCSV = [[String]]()
    
    
    //MARK: - life cycle
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearDatabase()
        readDataFromCSVFile(file: csvFile)
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
    
    
    
    //MARK: - statistic calculations
    /***************************************************************/
    
    /**
     returns the total of counted pilz objects
     from data array
     - Returns: Int
    */
    func getTotalOfClasses() -> Int {
        return dataArray.count
    }
    
    
    /**
     calculates the entropy of all identical classes
     from data array
     - Returns: Int
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
     - Params: entropy of all classes
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
     - parameters:
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
     - parameters:
     - String:  key of property
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
    
//    func countClasses(for key : String){
//
//        var temp = [String : Int]()
//        var counter = 0
//        let total = dataArray.count
//        for item in dataArray {
//
//            //print(item.value(forKeyPath: key))
//
//            let val = item.value(forKeyPath: key) as! String
//
//            if !temp.keys.contains(val){
//                counter = 0
//                temp[val] = counter + 1
//            } else {
//                counter = temp[val]!
//                counter = counter + 1
//                temp.updateValue(counter, forKey: val)
//            }
//        }
//
//        for value in temp {
//            print("-------------   \(key) : wert \(value.key) : count: \(value.value)")
//            countClassesOfProperty(for: key, and: value.key, counted: value.value)
//        }
//        entropyClasses = calcEntropyOfPropertiesClasses(array: temp, total: total)
//    }
//
//    func countClassesOfProperty(for key : String, and value : String, counted : Int){
//        var temp = [String : Int]()
//        var counter = 0
//
//        for item in dataArray {
//
//            let val = item.value(forKeyPath: key) as! String
//
//            if val == value {
//                if !temp.keys.contains(item.klasse!){
//                    counter = 0
//                    temp[item.klasse!] = counter + 1
//                } else {
//                    counter = temp[item.klasse!]!
//                    counter = counter + 1
//                    temp.updateValue(counter, forKey: item.klasse!)
//                }
//            }
//        }
//        for value in temp {
//            print("+++++++++++++++++ \(key) : wert \(value.key) : count: \(value.value)")
//        }
//
//        entropyClasses = calcEntropyOfPropertiesClasses(array: temp, total : counted)
//
//    }
//
//    //calls the countClasses for all items of Pilz with the
//    //with the propertys
//    func countAll(){
//        for item in keyArray {
//            countClasses(for: item)
//        }
//    }
//
//
//    func calcEntropyOfPropertiesClasses(array : [String : Int], total : Int) -> Float{
//        var number : Float = 0
//        let total = Float(total)
//
////        for val in array {
////            total += Float(val.value)
////            print("+++++++++++++++++++++++++++++++++ Addition total \(total)")
////        }
//
//        print("************************************* Summe total \(total)")
//
//        for klasse in array {
//            let x = Float(klasse.value)/total
//            number += -(x * log2(x))
//            print("klasse: \(klasse) entropy:  \(number)")
//        }
//        print(number)
//        return number
//    }
//
//
//    func calcEntropyClasses(array : [String : Int]) -> Float{
//               var number : Float = 0
//                let total = Float(dataArray.count)
//
//                for klasse in array {
//                  let x = Float(klasse.value)/total
//                   number += -(x * log2(x))
//                   print("klasse: \(klasse) entropy:  \(number)")
//               }
//               print(number)
//              return number
//     }
//

    //MARK: - methods for CSV parsing and Core Data
    /***************************************************************/
    
    func readDataFromCSVFile(file:String) {
        guard let path = Bundle.main.path(forResource: file, ofType: "csv") else {return}
        print (path)
        let contentsOfURL = URL(fileURLWithPath: path)
        print(contentsOfURL)
        parseCSV(contentsOfURL: contentsOfURL, encoding: String.Encoding.macOSRoman)
    }
    
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
        createDataForDataBase(array: dataArrayCSV)
    }
    
    
    //removes empty coloums of csv file
    func cleanArray(data : [ String ]) -> [String]{
        var arrayTemp = [String]()
        for item in data {
            if item != "" {
                arrayTemp.append(item)
            }
        }
        return arrayTemp
    }
    
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
    
    func createDataForDataBase (array: [[ String ]]){
            for item in array {
                let newItem = Pilz(context: context)
                
                newItem.klasse = item[0]
                newItem.busch = item[1]
                newItem.hutFormAlt = item[2]
                newItem.hutFormJung = item[3]
                newItem.hutOberflaeche = item[4]
                newItem.hutUnterseite = item[5]
                newItem.hutUnterseiteFarbe = item[6]
                newItem.huVerfaerbung = item[7]
                newItem.huVerfaerbungFarbe = item[8]
                newItem.hutFarbe = item[9]
                newItem.stielForm = item[10]
                newItem.stielBasis = item[11]
                newItem.stielFarbe = item[12]
                newItem.stielOberflaeche = item[13]
                newItem.stielNetzFlockenFarbe = item[14]
                newItem.stielRing = item[15]
                newItem.stielBasisVolva = item[16]
                newItem.stielHohl = item[17]
                newItem.fleischFarbe = item[18]
                newItem.fleischVerfaerbung = item[19]
                newItem.fleischVerfaerbungFarbe = item[20]
                newItem.geruch = item[21]
                
                saveItem()
            }
   
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
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
        //print(dataArray)
    }
    


}
