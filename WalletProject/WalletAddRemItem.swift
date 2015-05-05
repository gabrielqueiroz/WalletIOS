//
//  WalletAddRemItem.swift
//  WalletProject
//
//  Created by Gabriel Queiroz on 4/25/15.
//  Copyright (c) 2015 Gabriel Queiroz. All rights reserved.
//

import UIKit

class WalletAddRemItem: UIViewController {
    
    var databasePath = NSString()
    
    var itemID = NSString()
    var operation = NSString()
    var oldValue = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = operation as String
        
        println("DEBUG ITEM \(itemID) OPERATION \(operation) OLD VALUE \(oldValue)")
        
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
        
        loadReferences()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var addOne: UIButton!
    @IBOutlet weak var addFive: UIButton!
    @IBOutlet weak var addTen: UIButton!
    @IBOutlet weak var addTwenty: UIButton!

    @IBAction func addValue(sender: UIButton) {
        var val = 0.0
        
        if(sender == addOne){
            val = (value.text as NSString).doubleValue + 1.00
            value.text = val.description
        }
        if(sender == addFive){
            val = (value.text as NSString).doubleValue + 5.00
            value.text = val.description
        }
        if(sender == addTen){
            val = (value.text as NSString).doubleValue + 10.00
            value.text = val.description
        }
        if(sender == addTwenty){
            val = (value.text as NSString).doubleValue + 20.00
            value.text = val.description
        }
    }
    
    var picker = ["-"]
    
    func loadReferences(){
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            
            let querySQL = "SELECT NAME FROM REFERENCE WHERE ITEMFK='\(itemID)'"
        
            var results:FMResultSet? = itemDB.executeQuery(querySQL,
            withArgumentsInArray: nil)
            
            if(results?.next() == false){
                var insertSQL = "INSERT INTO REFERENCE (NAME, ITEMFK) VALUES ('Others','\(itemID)')"
                var result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                if !result {
                    println("Warn: FAILED TO ADD A NEW REFERENCE")
                }

                insertSQL = "INSERT INTO REFERENCE (NAME, ITEMFK) VALUES ('Restaurant','\(itemID)')"
                result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                if !result {
                    println("Warn: FAILED TO ADD A NEW REFERENCE")
                }
                insertSQL = "INSERT INTO REFERENCE (NAME, ITEMFK) VALUES ('Grocery','\(itemID)')"
                result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                if !result {
                    println("Warn: FAILED TO ADD A NEW REFERENCE")
                }
                insertSQL = "INSERT INTO REFERENCE (NAME, ITEMFK) VALUES ('Outlet','\(itemID)')"
                result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                if !result {
                    println("Warn: FAILED TO ADD A NEW REFERENCE")
                }
                insertSQL = "INSERT INTO REFERENCE (NAME, ITEMFK) VALUES ('Fast Food','\(itemID)')"
                result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                if !result {
                    println("Warn: FAILED TO ADD A NEW REFERENCE")
                }
                loadReferences()
            } else {
                let name = results?.stringForColumn("name")
                picker.insert(name!, atIndex: 1)
                while(results?.next() == true) {
                    let name = results?.stringForColumn("name")
                    picker.insert(name!, atIndex: 1)
                }
            }
            
            itemDB.close()
            
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    func insertReference(){
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let insertSQL = "INSERT INTO REFERENCE (NAME, ITEMFK) VALUES ('\(reference.text)','\(itemID)')"
            let result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            if !result {
                println("Warn: FAILED TO ADD A NEW REFERENCE")
            }
            
            itemDB.close()
            
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    func deleteReference(){
        let itemDB = FMDatabase(path: databasePath as String)
        
        if itemDB.open() {
            let insertSQL = "DELETE FROM REFERENCE WHERE NAME=('\(pickerValue)')"
            let result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            if !result {
                println("Warn: FAILED TO DELETE A REFERENCE")
            } else {
                println("Warn: DELETED A REFERENCE")}

            itemDB.close()
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
    }
    
    var pickerValue = String()

    @IBOutlet weak var pickerUI: UIPickerView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return picker.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        pickerValue = picker[row]
        reference.text = picker[row]
        return picker[row]
    }
    
    @IBOutlet weak var reference: UITextField!
    
    @IBAction func addReference(sender: UIButton) {
        insertReference()
        picker.insert(reference.text, atIndex: 1)
        pickerUI.reloadAllComponents()
    }
    
    @IBAction func remReference(sender: UIButton) {
        deleteReference()
        picker = ["-"]
        loadReferences()
        pickerUI.reloadAllComponents()
    }
    
    func confirmAction(){
        let itemDB = FMDatabase(path: databasePath as String)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .ShortStyle
        let date = formatter.stringFromDate(NSDate())

        
        if itemDB.open() {
            
            let insertSQL = "INSERT INTO HISTORY (ITEMFK, VALUE, REFERENCE, DATE, OPERATION) VALUES ('\(itemID)','\(value.text)','\(reference.text)','\(date)','\(operation.lowercaseString)')"
            
            var result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result {
                println("Warn: FAILED TO ADD HISTORY")
                println("Error: \(itemDB.lastErrorMessage())")
            } else {
                println("Warn: HISTORY ADDED")
            }
            
            var newValue = Double()
            
            if(operation == "Adding"){
                newValue = (oldValue as NSString).doubleValue + (value.text as NSString).doubleValue
            }else if(operation == "Removing"){
                newValue = (oldValue as NSString).doubleValue - (value.text as NSString).doubleValue
            }
            
            let querySQL = "UPDATE ITEMS SET VALUE='\(newValue.description)' WHERE ITEMID='\(itemID)'"
            
            result = itemDB.executeUpdate(querySQL, withArgumentsInArray: nil)
            
            if !result {
                println("Warn: FAILED TO UPDATE ITEM")
                println("Error: \(itemDB.lastErrorMessage())")
            } else {
                println("Warn: ITEM UPDATED")
            }

        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func displayReferenceAlert(){
        let alertController = UIAlertController(title: "Warning", message: "You need to type a reference", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayValueAlert(){
            let alertController = UIAlertController(title: "Warning", message: "You need to type a value", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func confirmButton(sender: AnyObject) {
        if (value.text == ""){
            displayValueAlert()
        } else if (reference.text == "" || reference.text == "-"){
            displayReferenceAlert()
        } else {
            confirmAction()
        }
        
    }
    
}
