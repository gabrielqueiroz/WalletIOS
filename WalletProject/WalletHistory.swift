//
//  WalletHistory.swift
//  WalletProject
//
//  Created by Gabriel Queiroz on 4/25/15.
//  Copyright (c) 2015 Gabriel Queiroz. All rights reserved.
//

import UIKit

class WalletHistory: UITableViewController {
    
    var itemID = NSString()
    
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as! String
        
        databasePath = docsDir.stringByAppendingPathComponent("wallet_0.5.db")
        
        if !filemgr.fileExistsAtPath(databasePath as String) {
            
            let itemDB = FMDatabase(path: databasePath as String)
            
            if itemDB == nil {
                println("Error: \(itemDB.lastErrorMessage())")
            }
            
        }
        
        loadAllItems()
    }
    
    var dates = Array<String>()
    var values = Array<String>()
    var locals = Array<String>()
    var icons = Array<String>()
    
    func loadAllItems(){
        
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let querySQL = "SELECT * FROM HISTORY WHERE ITEMFK='\(itemID)'"
            
            let results:FMResultSet? = itemDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            
            while(results?.next() == true) {
                let date = results?.stringForColumn("date")
                let value = results?.stringForColumn("value")
                let local = results?.stringForColumn("reference")
                let icon = results?.stringForColumn("operation")
                dates.insert(date!, atIndex: 0)
                values.insert(value!, atIndex: 0)
                locals.insert(local!, atIndex: 0)
                icons.insert(icon!, atIndex: 0)
            }
            itemDB.close()
            
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int)
        -> Int {
            return self.values.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let value = self.values[indexPath.row]
            let date = self.dates[indexPath.row]
            let icon = self.icons[indexPath.row]
            let local = self.locals[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.text = "On \(date) \n$\(value) with \(local)"
            cell.imageView?.image = UIImage(named: icon)
            
            return cell
    }

}
