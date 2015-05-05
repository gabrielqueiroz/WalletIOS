//
//  WalletMain.swift
//  WalletProject
//
//  Created by Gabriel Queiroz on 4/24/15.
//  Copyright (c) 2015 Gabriel Queiroz. All rights reserved.
//

import UIKit

class WalletMain: UITableViewController {
    
    var databasePath = NSString()
    
    override func viewDidAppear(animated: Bool) {
        loadAllItems()
        self.tableView.reloadData()
    }
    
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
            
            if itemDB.open() {
                var sql_stmt = "CREATE TABLE IF NOT EXISTS ITEMS ( ITEMID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, VALUE TEXT, ICON TEXT)"
                
                if !itemDB.executeStatements(sql_stmt) {
                    println("Error: \(itemDB.lastErrorMessage())")
                }
                
                sql_stmt = "CREATE TABLE IF NOT EXISTS HISTORY ( HISTORYID INTEGER PRIMARY KEY AUTOINCREMENT, VALUE TEXT, REFERENCE TEXT, DATE TEXT, ITEMFK INTEGER, OPERATION TEXT, FOREIGN KEY (ITEMFK) REFERENCES ITEM (ITEMID))"
                
                if !itemDB.executeStatements(sql_stmt) {
                    println("Error: \(itemDB.lastErrorMessage())")
                }

                sql_stmt = "CREATE TABLE IF NOT EXISTS REFERENCE ( REFERENCEID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ITEMFK INTEGER, FOREIGN KEY (ITEMFK) REFERENCES ITEM (ITEMID))"
                
                if !itemDB.executeStatements(sql_stmt) {
                    println("Error: \(itemDB.lastErrorMessage())")
                }
                
                itemDB.close()
            } else {
                println("Error: \(itemDB.lastErrorMessage())")
            }
            
        }
        
        loadInitialValues()
        loadAllItems()
    }

    func loadInitialValues(){
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let querySQL = "SELECT name, value, icon FROM ITEMS"
            let results:FMResultSet? = itemDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            
            if(results?.next() == true) {
                //println("Warn: TABLE ALREADY POPULATED")
            } else {
                
                var insertSQL = "INSERT INTO ITEMS (name, value, icon) VALUES ('Wallet', '10.0', 'wallet')"
                var result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                
                if !result {
                    println("Error: \(itemDB.lastErrorMessage())")
                }
                
                insertSQL = "INSERT INTO ITEMS (name, value, icon) VALUES ('Bank', '900.0', 'bank')"
                result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                
                if !result {
                    println("Error: \(itemDB.lastErrorMessage())")
                }
                
                insertSQL = "INSERT INTO ITEMS (name, value, icon) VALUES ('Credit Card', '100.0', 'creditcard')"                
                result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                
                if !result {
                    println("Error: \(itemDB.lastErrorMessage())")
                }
            }
            
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    var names = Array<String>()
    var values = Array<String>()
    var icons = Array<String>()
    
    func loadAllItems(){
        names = Array<String>()
        values = Array<String>()
        icons = Array<String>()
        
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let querySQL = "SELECT name, value, icon FROM ITEMS"
            
            let results:FMResultSet? = itemDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            
            while(results?.next() == true) {
                var name = results?.stringForColumn("name")
                var value = results?.stringForColumn("value")
                var icon = results?.stringForColumn("icon")
                names.insert(name!, atIndex: 0)
                values.insert(value!, atIndex: 0)
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
            return self.names.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let name = self.names[indexPath.row]
            let value = self.values[indexPath.row]
            let icon = self.icons[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.text = name+"\n$ "+value
            cell.imageView?.image = UIImage(named: icon)
            
            return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let name = self.names[indexPath.row]
            names.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            deleteItem(name)
        }
    }

    func deleteItem(toDelete: String){
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let querySQL = "DELETE FROM ITEMS WHERE name = '\(toDelete)'"
            
            let result = itemDB.executeUpdate(querySQL, withArgumentsInArray: nil)
            
            if !result {
                //println("Warn: FAILED TO DELETE")
            } else {
                //println("Warn: RECORD DELETED")
            }
            
            itemDB.close()
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "manageItem" {
            if let destination = segue.destinationViewController as? WalletManageItem {
                if let itemIndex = tableView.indexPathForSelectedRow()?.row {
                    destination.tableItem = names[itemIndex]
                }
            }
        }
    }
    
}

