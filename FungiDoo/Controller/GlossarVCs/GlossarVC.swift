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
import CoreData

class GlossarVC: UIViewController {

    //MARK: Constants & Variables
    /***************************************************************/
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //private var authorizedSet = false
    private let JSON_URL = "https://kfraeger.de/fungiDoo/pilzeList.json"
    private let IMAGE_BASE_URL = "https://kfraeger.de/fungiDoo/images/"
    
    let imageCache = NSCache<NSString, UIImage>()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    var data = [PilzGlossar]()
    var filteredData = [PilzGlossar]() //for searching
    
    var sectionIndices = [String]()
    var rowsSection   = [[PilzGlossar]]()
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
        loadItems()
        configureTableView()
        configureSearchController()
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
            
            if let index = item.name{
                let key = String(index.first!)
                if !sectionIndices.contains(key){
                    sectionIndices.append(key)
                }
                
            }
        }
        
    }
    
    //Sorts rows to the generated sections
    func getRowsForSection(){
        //print("getRowsForSection()")
        var tempArr : [PilzGlossar] = []
        for index in sectionIndices{
            for item in data {
                if index == String(item.name!.first!) {
                    tempArr.append(item)
                }
            }
            rowsSection.append(tempArr)
            tempArr = []
        }
    }
    
    //MARK: - Segues
    /***************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToGlossarDetail"{
            let destinationVC = segue.destination as! GlossarDetailVC
            
            destinationVC.pilzData = (searching ? filteredData[indexOfRow] : rowsSection[indexOfSection][indexOfRow])
            destinationVC.eatableIcon = (searching ? self.updateEatableIcon(condition: filteredData[indexOfRow].eatable!) : self.updateEatableIcon(condition: rowsSection[indexOfSection][indexOfRow].eatable!))
            
        }
    }
    
    /**
     loads all items from core data
     */
    func loadItems(){
        let request : NSFetchRequest<PilzGlossar> = PilzGlossar.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            data = try context.fetch(request)
            
        } catch {
            print("Error in fetching Items \(error)")
        }
        
        generatedABCIndexForSection()
        getRowsForSection()
        self.glossarTableView.reloadData()
    }
    
    //This method turns a condition code into the name of the eatable condition image
    func updateEatableIcon(condition: String) -> String {
        
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
            cell.glossarImageView.image = UIImage(named: filteredData[indexPath.row].imageURL!)
            cell.nameLabel.text = filteredData[indexPath.row].name
            cell.lateinNameLabel.text = filteredData[indexPath.row].lateinName
            
            let eatIconUrl = self.updateEatableIcon(condition: filteredData[indexPath.row].eatable!)
            cell.glossarEatableImaveView.image = UIImage(named: eatIconUrl)
            
            
            
        } else {
            cell.glossarImageView.image = UIImage(named: rowsSection[indexPath.section][indexPath.row].imageURL!)
            cell.nameLabel.text = rowsSection[indexPath.section][indexPath.row].name
            cell.lateinNameLabel.text = rowsSection[indexPath.section][indexPath.row].lateinName
            
            let eatIconUrl = self.updateEatableIcon(condition: rowsSection[indexPath.section][indexPath.row].eatable!)
            cell.glossarEatableImaveView.image = UIImage(named: eatIconUrl)
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
            filteredData = data.filter { $0.name!.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        self.glossarTableView.reloadData()
    }
    
}
