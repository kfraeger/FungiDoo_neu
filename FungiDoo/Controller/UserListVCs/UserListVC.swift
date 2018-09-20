//
//  UserListViewController.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 18.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import CoreData

class UserListVC: UIViewController {

    
    //MARK: - Variables & Constants
    /***************************************************************/
    
    let infoLabelText = "Hier kannst du alle deine Pilzfunde eintragen. \n\nDiese Einträge sind nur für dich sichtbar."
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var indexRow = 0
    var dataArray = [UserItem]()
    
    //MARK: - Outlets
    /***************************************************************/
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var userListItemsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadItems), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        configureInfoLabel()
        loadItems()
        swichtVisibilityInfoLabelAndTableView()
        configureTableView()
    }
    
    func configureTableView(){
        userListItemsTableView.delegate = self
        userListItemsTableView.dataSource = self
        userListItemsTableView.rowHeight = 180.0
        userListItemsTableView.register(UINib(nibName: "UserItemTableViewCell", bundle: nil), forCellReuseIdentifier: "UserItemCell")
    }
    
    func configureInfoLabel(){
        infoLabel.text = infoLabelText
    }

    func checkIfDataArrayLengthIsNull () -> Bool {
        return (dataArray.count == 0 ? true : false)
    }
    
    func swichtVisibilityInfoLabelAndTableView() {
        infoLabel.isHidden = checkIfDataArrayLengthIsNull() ? false : true
        userListItemsTableView.isHidden = checkIfDataArrayLengthIsNull() ? true : false
    }
    
    func optionButtonPressed(cellForRowAt indexPath : Int){
        print(indexPath)
        //addButtonPressed = false
        indexRow = indexPath
        showActionSheet()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToUserItemDetail"{
            let destinationVC = segue.destination as! UserListDetailVC
            
            destinationVC.userData = dataArray[indexRow]
        }
    }
    
    //MARK: - Core Data methods
    /***************************************************************/
    
    @objc func loadItems(){
        
        let request : NSFetchRequest<UserItem> = UserItem.fetchRequest()
        
        do {
            dataArray = try context.fetch(request)
        } catch {
            print("Error in fetching Items \(error)")
        }
        userListItemsTableView.reloadData()
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.userListItemsTableView.reloadData()
    }
    
    func deleteItem(at index : Int){
        
        context.delete(dataArray[index])
        dataArray.remove(at: index)
        saveItems()
    }
    
    
    //MARK: - ActionSheet
    /***************************************************************/
    
    func showActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Öffnen", comment: "open"), style: .default, handler: { _ in
            NSLog("The \"Öffnen\" alert occured.")
            self.performSegue(withIdentifier: "goToMyPilzDetail", sender: self)
        }))
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Bearbeiten", comment: "Default action"), style: .default, handler: { _ in
//            NSLog("The \"Bearbeiten\" alert occured.")
//            self.performSegue(withIdentifier: "goToEditView", sender: self)
//        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Löschen", comment: "delete"), style: .destructive, handler: { _ in
            NSLog("The \"Löschen\" alert occured.")
            print(self.indexRow)
            self.deleteItem(at: self.indexRow)
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Abbrechen", comment: "cancel"), style: .cancel, handler: { _ in
            NSLog("The \"Cancel\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}




//MARK: - Extension TableView Delegate Methods
/***************************************************************/

extension UserListVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserItemCell", for: indexPath) as! UserItemTableViewCell
        
        cell.nameLabel.text = dataArray[indexPath.row].name
        cell.dateLabel.text = dataArray[indexPath.row].date?.description
        cell.locationLabel.text = dataArray[indexPath.row].location
        cell.avatarImageView.image = UIImage(data: dataArray[indexPath.row].image! )
        
        cell.onButtonTapped = {
            self.optionButtonPressed(cellForRowAt: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("perform seque goToMyPilzDetail")
        indexRow = indexPath.row
        performSegue(withIdentifier: "goToUserItemDetail", sender: self)
        userListItemsTableView.deselectRow(at: indexPath, animated: true)
        
    }
}

