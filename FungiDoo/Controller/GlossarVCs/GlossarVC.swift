//
//  GlossarVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 17.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class GlossarVC: UIViewController {

    //MARK: Constants & Variables
    /***************************************************************/
    
    //private var authorizedSet = false
    private let JSON_URL = "https://kfraeger.de/fungiDoo/pilzeList.json"
    private let IMAGE_BASE_URL = "https://kfraeger.de/fungiDoo/images/"
    
    let imageCache = NSCache<NSString, UIImage>()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    var data = [Pilze]()
    var filteredData = [Pilze]() //for searching
    
    var sectionIndices : [String] = []
    var rowsSection : [[Pilze]] = []
    var indexOfRow = 0
    var indexOfSection = 0
    var searching = false
    
    //MARK: IBOutlets
    /***************************************************************/
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var glossarTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.isHidden = true
        getJSONData(url: JSON_URL)
        configureTableView()
        configureSearchController()
        // Do any additional setup after loading the view.
    }

    
    
    private func configureTableView(){
        glossarTableView.delegate = self
        glossarTableView.dataSource = self
        glossarTableView.tableHeaderView = searchController.searchBar
        
        //Registering your custom cell xib
        glossarTableView.register(UINib(nibName: "GlossarListTableViewCell", bundle: nil), forCellReuseIdentifier: "GlossarListCell")
        glossarTableView.rowHeight = 120.0
    }
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    
    
    //shows and  hides NOResultLabel for the search
    func switchShowHideInfoLabel(number : Int){
        infoLabel.isHidden = (number != 0 ? true : false)
        
    }
    
    //Generates the indices for the table sections from first letter of name
    func generatedABCIndexForSection(){
        //print("generatedABCIndexForSection()")
        for item in data {
            
            let index = String(item.name[item.name.startIndex])
            let key = index.uppercased()
            
            if !sectionIndices.contains(key){
                sectionIndices.append(key)
            }
        }
        
    }
    
    //Sorts rows to the generated sections
    func getRowsForSection(){
        //print("getRowsForSection()")
        var tempArr : [Pilze] = []
        for index in sectionIndices{
            for item in data {
                if index == String(item.name[item.name.startIndex]) {
                    tempArr.append(item)
                }
            }
            rowsSection.append(tempArr)
            tempArr = []
        }
    }
    
    //Sorts the listing data alphabetically
    func sortDataListABCAsc(){
        data = data.sorted(by: { $0.name < $1.name})
    }
    
    //MARK: - Segues
    /***************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToGlossarDetail"{
            let destinationVC = segue.destination as! GlossarDetailVC
            
            destinationVC.pilzData = (searching ? filteredData[indexOfRow] : rowsSection[indexOfSection][indexOfRow])
        }
    }

}




//MARK: - Extension TableView Delegate Methods
/***************************************************************/

extension GlossarVC: UITableViewDelegate, UITableViewDataSource {
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndices
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = (searching ? "Suchergebnis" : sectionIndices[section])
        return title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let number = (searching ? 1 : sectionIndices.count)
        return number
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = (searching ? filteredData.count : rowsSection[section].count)
        switchShowHideInfoLabel(number: number)
        return number
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexOfSection = indexPath.section
        indexOfRow = indexPath.row
        performSegue(withIdentifier: "goToGlossarDetail", sender: self)
        glossarTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlossarListCell", for: indexPath) as! GlossarListTableViewCell
        
        if searching {
            cell.glossarImageView.image = filteredData[indexPath.row].image
            cell.nameLabel.text = filteredData[indexPath.row].name
            cell.lateinNameLabel.text = filteredData[indexPath.row].latein
            cell.glossarEatableImaveView.image = UIImage(named: filteredData[indexPath.row].eatableIconString)
        } else {
            cell.glossarImageView.image = rowsSection[indexPath.section][indexPath.row].image
            cell.nameLabel.text = rowsSection[indexPath.section][indexPath.row].name
            cell.lateinNameLabel.text = rowsSection[indexPath.section][indexPath.row].latein
            cell.glossarEatableImaveView.image = UIImage(named: rowsSection[indexPath.section][indexPath.row].eatableIconString)
        }
        return cell
    }
}

//MARK: - Extension SearchBar Updating Methods
/***************************************************************/

extension GlossarVC : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredData = data
            searching = false
        } else {
            searching = true
            filteredData = data.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        self.glossarTableView.reloadData()
    }
    
}

//MARK: - Network JSON Parsing & ImageService
/***************************************************************/
extension GlossarVC {

    // get JSON data from URL
    func getJSONData(url : String) {
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess{
                //print("Success! Daten erhalten")
                let dataJSON : JSON = JSON(response.result.value!)
                self.updateDictonaryWithJSONData(json: dataJSON)
            } else {
                print("Error : \(String(describing: response.result.error))")
                
                AlertService.showErrorConnectionAlert(on: self)
                
            }
        }
    }
    
    //update dictonary with json data
    func updateDictonaryWithJSONData(json : JSON) {
        if let tempResult = json.array {
            for item in 0 ... tempResult.count - 1 {
                
                let newDataItem = Pilze()
                
                newDataItem.name = json[item]["name"].stringValue
                newDataItem.beschreibung = json[item]["beschreibung"].stringValue
                newDataItem.latein = json[item]["latein"].stringValue
                newDataItem.essbar = json[item]["essbar"].stringValue
                newDataItem.eatableIconString = newDataItem.updateEatableIcon(condition: newDataItem.essbar)
                newDataItem.dateRange = json[item]["date_range"].stringValue
                newDataItem.family = json[item]["family"].stringValue
                newDataItem.imageURL = json[item]["imageURL"].stringValue
                getImageData(for : newDataItem, from: json[item]["imageURL"].stringValue)
                data.append(newDataItem)
                
            }
            sortDataListABCAsc()
            generatedABCIndexForSection()
            getRowsForSection()
            self.glossarTableView.reloadData()
        }
        
    }
    
    //load image from url
    func getImageData(for data: Pilze, from url : String){
        //print(dataDictonary.count)
        
        if url != "" {
            if let imageFromCache = imageCache.object(forKey: url as NSString) {
                data.image = imageFromCache
                return
            }
            
            Alamofire.request("\(IMAGE_BASE_URL)\(url)", method: .get).responseImage { response in
                guard let imageResponse = response.result.value else {
                    print(response.error as Any)
                    return
                }
                data.image = imageResponse
                self.imageCache.setObject(data.image, forKey: data.imageURL as NSString)
                self.glossarTableView.reloadData()
            }
        }
        
        
    }
}

