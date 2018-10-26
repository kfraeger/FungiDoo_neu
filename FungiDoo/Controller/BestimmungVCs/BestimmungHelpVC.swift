//
//  BestimmungHelpVC.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 26.10.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit
import CoreData

class BestimmungHelpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let rowHeight : CGFloat = 110
    var category : String?
    var items = [QuestionDB]()
    
    
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let type = category {
            loadItems(name: type)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
    }
    
    /**
     get certain objects
     */
    func loadItems(name : String) {
        
        let request : NSFetchRequest<QuestionDB> = QuestionDB.fetchRequest()
        request.predicate = NSPredicate(format: "questionType == %@", name)
        
        do {
            items = try context.fetch(request)
            self.tableView.reloadData()
            
        } catch {
            print("Error in fetching Items \(error)")
        }
    }
    
    

    //MARK: - tableView methods
    /***************************************************************/
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "helpCellBestimmung", for: indexPath) as! BestimmungHelpTableViewCell
        
            cell.imageViewCell.image = UIImage(named: items[indexPath.row].questionImageURL!)
            cell.labelCell.text = items[indexPath.row].questionType
        

       return cell
    }
}
