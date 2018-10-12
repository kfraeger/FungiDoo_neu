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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dataArray = [Pilz]()
   
    let csvFile = "Daten"
    let delimiterCSV = ";"
    
    
    var dataArrayTemp = [Any]()
    var dataDict = [[String : String]]()
    var arrayKeyEntropies = [String : Float]()
    var keyArray = [String]()
    var totalNumberOfClasses  = 0
    var entropyClasses : Float = 0
    
    var dataArrayCSVHeader = [String]()
    var dataArrayCSV = [[String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearDatabase()
        readDataFromCSVFile(file: csvFile)
        loadItems()
        
        countAll()
        
    }
    
    func countClasses(for key : String){
        
        var temp = [String : Int]()
        var counter = 0
        for item in dataArray {
            
            //print(item.value(forKeyPath: key))
            
            let val = item.value(forKeyPath: key) as! String
            
            if !temp.keys.contains(val){
                counter = 0
                temp[val] = counter + 1
            } else {
                counter = temp[val]!
                counter = counter + 1
                temp.updateValue(counter, forKey: val)
            }
        }
        
        for value in temp {
            print("-------------   \(key) : wert \(value.key) : count: \(value.value)")
            countClassesOfProperty(for: key, and: value.key, counted: value.value)
        }
        //entropyClasses = calcEntropyClasses(array: temp)
    }
    
    func countClassesOfProperty(for key : String, and value : String, counted : Int){
        var temp = [String : Int]()
        var counter = 0

        for item in dataArray {
            
            let val = item.value(forKeyPath: key) as! String
            
            if val == value {
                if !temp.keys.contains(item.klasse!){
                    counter = 0
                    temp[item.klasse!] = counter + 1
                } else {
                    counter = temp[item.klasse!]!
                    counter = counter + 1
                    temp.updateValue(counter, forKey: item.klasse!)
                }
            }
        }
        for value in temp {
            print("+++++++++++++++++ \(key) : wert \(value.key) : count: \(value.value)")
        }
        
        entropyClasses = calcEntropyClasses(array: temp)

    }
    
    //calls the countClasses for all items of Pilz with the
    //with the propertys
    func countAll(){
        for item in keyArray {
            countClasses(for: item)
        }
    }
    

    
    func calcEntropyClasses(array : [String : Int]) -> Float{
               var number : Float = 0
                let total = Float(dataArray.count)
       
                for klasse in array {
                  let x = Float(klasse.value)/total
                   number += -(x * log2(x))
                   print("klasse: \(klasse) entropy:  \(number)")
               }
               print(number)
              return number
     }
    

    
    
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
                newItem.hutFormAlt = item[1]
                newItem.hutFormJung = item[2]
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
                newItem.stielBasisVolvaFrei = item[16]
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
