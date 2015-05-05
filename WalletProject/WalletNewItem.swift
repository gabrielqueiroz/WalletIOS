//
//  WalletNewItem.swift
//  WalletProject
//
//  Created by Gabriel Queiroz on 4/25/15.
//  Copyright (c) 2015 Gabriel Queiroz. All rights reserved.
//

import UIKit

class WalletNewItem: UIViewController {

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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var itemName: UITextField!
    
    @IBOutlet weak var iconCenter: UIImageView!
    
    @IBOutlet weak var iconLeft: UIImageView!
    
    @IBOutlet weak var iconRight: UIImageView!
    
    @IBOutlet weak var sliderValue: UISlider!
    
    @IBAction func changeIcon(sender: AnyObject) {
        switch Int(sliderValue.value) {
            case 0:
                iconLeft.image = nil
                iconCenter.image = UIImage(named: "creditcard")
                iconRight.image = UIImage(named: "wallet")
            case 1:
                iconLeft.image = UIImage(named: "creditcard")
                iconCenter.image = UIImage(named: "wallet")
                iconRight.image = UIImage(named: "bank")
            case 2:
                iconLeft.image = UIImage(named: "wallet")
                iconCenter.image = UIImage(named: "bank")
                iconRight.image = UIImage(named: "shopcart")
            case 3:
                iconLeft.image = UIImage(named: "bank")
                iconCenter.image = UIImage(named: "shopcart")
                iconRight.image = nil
            default:
                iconCenter.image = UIImage(named: "wallet")
        }
    }
    
    @IBOutlet weak var itemValue: UITextField!
    
    @IBOutlet weak var addOne: UIButton!
    
    @IBOutlet weak var addFive: UIButton!
    
    @IBOutlet weak var addTen: UIButton!
    
    @IBAction func addValue(sender: UIButton) {
        var value = 0.0
        
        if(sender == addOne){
            value = (itemValue.text as NSString).doubleValue + 1.00
            itemValue.text = value.description
        }
        if(sender == addFive){
            value = (itemValue.text as NSString).doubleValue + 5.00
            itemValue.text = value.description
        }
        if(sender == addTen){
            value = (itemValue.text as NSString).doubleValue + 10.00
            itemValue.text = value.description
        }
    }
    
    @IBAction func createItem(sender: AnyObject) {
        let itemDB = FMDatabase(path: databasePath as String)
        
        var itemIcon = String()
        
        switch Int(sliderValue.value) {
            case 0: itemIcon = "creditcard"
            case 1: itemIcon = "wallet"
            case 2: itemIcon = "bank"
            case 3: itemIcon = "shopcart"
            default: itemIcon = "wallet"
        }
        
        if(itemValue.text == ""){
            itemValue.text = "00.00"
        }
        
        if itemDB.open() {
            
            let insertSQL = "INSERT INTO ITEMS (name, value, icon) VALUES ('\(itemName.text)', '\(itemValue.text)', '\(itemIcon)')"
            
            let result = itemDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result {
                println("Warn: FALIED TO ADD ITEM")
                println("Error: \(itemDB.lastErrorMessage())")
            } else {
                println("Warn: ITEM ADDED")
            }
            
        } else {
            println("Error: \(itemDB.lastErrorMessage())")
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
}
