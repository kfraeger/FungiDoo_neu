//
//  GlossarHelpViewController.swift
//  FungiDoo
//
//  Created by Katja Fraeger on 13.09.18.
//  Copyright © 2018 Katja Fraeger. All rights reserved.
//

import UIKit

class GlossarHelpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    //MARK: - Variables & Constants
    /***************************************************************/
    let sectionArray = ["Zeichenerklärung"]
    let textArray = ["tödlich giftig", "giftig", "ungenießbar", "eingeschränkt essbar", "essbar"]
    let iconArray = ["giftig-toedlich-icon", "giftig-icon", "ungeniessbar-icon", "beschraenkt-essbar-icon", "essbar-icon"]
    let sectionHeight : CGFloat = 50
    let rowHeight : CGFloat = 60
    
    
    //MARK: - IBOutlets
    /***************************************************************/
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - viewDidLoad
    /***************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
    }

    
    //MARK: - tableView methods
    /***************************************************************/
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = sectionArray[section]
        return title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlossarHelpCell", for: indexPath) as! GlossarHelpTableViewCell
        
        cell.iconImageView.image = UIImage(named: iconArray[indexPath.row])
        cell.iconHelpTextLabel.text = textArray[indexPath.row]
        
        return cell
    }
    

}
