//
//  ViewController.swift
//  WalletProject
//
//  Created by Gabriel Queiroz on 4/24/15.
//  Copyright (c) 2015 Gabriel Queiroz. All rights reserved.
//

import UIKit

class WalletManageItem: UIViewController {

    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = tableItem as String
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var tableItem = NSString()

    @IBOutlet weak var itemValue: UILabel!
    
    @IBOutlet weak var itemIcon: UIImageView!
    
    var itemID = String()
    var value = String()
    
    override func viewWillAppear(animated: Bool) {
        
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let querySQL = "SELECT ITEMID, VALUE, ICON FROM ITEMS WHERE name = '\(tableItem)'"
            
            let results:FMResultSet? = itemDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            
            if results?.next() == true {
                itemID = results!.intForColumn("itemid").description
                value = results!.stringForColumn("value")
                itemValue.text = "$ "+value
                let itemText = results?.stringForColumn("icon")
                itemIcon.image = UIImage(named: itemText!)
            }
            
            itemDB.close()
            
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "quickAdd" {
            if let destination = segue.destinationViewController as? WalletAddRemItem {
                destination.itemID = itemID
                destination.operation = "Adding"
                destination.oldValue = value
            }
        } else if segue.identifier == "quickRemove" {
            if let destination = segue.destinationViewController as? WalletAddRemItem {
                destination.itemID = itemID
                destination.operation = "Removing"
                destination.oldValue = value
            }
        } else if segue.identifier == "history" {
            if let destination = segue.destinationViewController as? WalletHistory {
                destination.itemID = itemID
            }
        }
        
    }
    
}

