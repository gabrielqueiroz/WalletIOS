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
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as! String
        
        databasePath = docsDir.stringByAppendingPathComponent("wallet_0.1.db")
        
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
    
    var picker = ["-","Restaurant","Grocery","Outlet","Fast Food"]
    
    @IBOutlet weak var pickerUI: UIPickerView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return picker.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return picker[row]
    }
    
    @IBOutlet weak var reference: UITextField!
    
    @IBAction func addReference(sender: UIButton) {
        picker.insert(reference.text, atIndex: 1)
        pickerUI.reloadAllComponents()
    }
    
    func confirmAction(action: String){
        let itemDB = FMDatabase(path: databasePath as String)
        
        let date = NSDate()
        
        if itemDB.open() {
            
            let insertSQL = "INSERT INTO HISTORY (ITEMFK, VALUE, REFERENCE, DATE, OPERATION) VALUES ('\(itemID)','\(value.text)','\(reference.text)','\(date)','\(operation)')"
            
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
    
}
