//
//  BestimmungsVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 10.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class BestimmungsVC: UIViewController {

    var arrayClassCount : [Float] = [2, 3, 2, 3, 2, 3, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2]
    var arrayTrain : [Float] = [6, 9]
    let csvFile = "Daten"
    let delimiterCSV = ";"
    var arrayKeyEntropies = [String : Float]()
    
    var dataArrayCSVHeader = [String]()
    var dataArrayCSV = [[String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        readDataFromCSVFile(file: csvFile)
        
        countElementsOfColoumns(at: 0, of: dataArrayCSV)
        calcEntropyOfClasses()
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
        arrayKeyEntropies = createEntropyArrayKeys(array: dataArrayCSV)
        dataArrayCSV = removeHeaderOfColoumn(array: dataArrayCSV)
        
        //print(dataArrayCSV)
    }
    
    
    //removes empty data compontents of csv file
    func cleanArray(data : [ String ]) -> [String]{
        var cleanArray = [String]()
        
        for item in data {
            if item != "" {
                cleanArray.append(item)
            }
        }
        return cleanArray
    }
    
    func createEntropyArrayKeys(array : [[String]]) -> [String : Float] {
        var arrayTemp = [String : Float]()
        
        for i in 0 ..< array.count{
            if i == 0 {
                for value in array[i]{
                    arrayTemp[value] = 0
                }
            }
        }
        print(arrayTemp)
        return arrayTemp
    }
    
    //removes the title Header from Array for calculation
    func removeHeaderOfColoumn(array : [[String]]) -> [[String]] {
        var arrayWithoutHeader = [[String]]()
        
        for i in 0 ..< array.count{
            if i != 0 {
                arrayWithoutHeader.append(array[i])
            }
        }
        return arrayWithoutHeader
    }
    

    //counts the number of rows of imported csv file
    func getTotalNumberOfClasses() -> Float{
        return Float(dataArrayCSV.count)
    }
    
    //calculates the total entropy of all classes
    func calcEntropyOfClasses() -> Float{
        
        var number : Float = 0
        let total = getTotalNumberOfClasses()
        
        for klasse in arrayClassCount {
            let x = klasse/total
            number += -(x * log2(x))
            print("klasse: \(klasse) entropy:  \(number)")
        }
        print(number)
        return number
    }
    
    
    
    
    
    func countElementsOfColoumns(at index : Int, of array : [[String]]) {
        var arrayCountExistensOfValue = [String : Int]()
        var countExistensOfValue = 0
        
        for item in array{
            let value = item[index]
            
            if !arrayCountExistensOfValue.keys.contains(value){
                
                countExistensOfValue = 0
                //print("neues Element \(value) : \(countExistensOfValue)")
                arrayCountExistensOfValue.updateValue(1, forKey: value)
            
            } else {
                
                countExistensOfValue  = arrayCountExistensOfValue[value]! + 1
                //print("existierendes Element \(value) : \(countExistensOfValue)")
                arrayCountExistensOfValue.updateValue(countExistensOfValue, forKey: value)
            }
        }
        print(arrayCountExistensOfValue)
        
    }

}
