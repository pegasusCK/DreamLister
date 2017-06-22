//
//  ItemDetailsVC.swift
//  DreamLister
//
//  Created by Chihkao Yu on 6/19/17.
//  Copyright © 2017 Chihkao Yu. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var priceField: CustomTextField!
    @IBOutlet weak var detailsField: CustomTextField!
   
    var stores = [Store]()
    var itemToEdit: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //replace the title so the name of the source segue VC doesn't show up on the ItemDetailsVC/ItemDetailsVCNew
        if let topItem = self.navigationController?.navigationBar.topItem {
            
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        storePicker.delegate = self
        storePicker.dataSource = self
        
//        let store = Store(context: context)
//        store.name = "Best Buy"
//        let store2 = Store(context: context)
//        store2.name = "Tesla Dealership"
//        let store3 = Store(context: context)
//        store3.name = "Frys Electronics"
//        let store4 = Store(context: context)
//        store4.name = "Target"
//        let store5 = Store(context: context)
//        store5.name = "Amazon"
//        let store6 = Store(context: context)
//        store6.name = "K-Mart"
//        
//        ad.saveContext()
        
        getStores()
        
        if itemToEdit != nil {
            
            loadItemData()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let store = stores[row]
  
        return store.name
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return stores.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //update when selected
    }
    
    func getStores() {
        
        let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
        
        do {
            self.stores = try context.fetch(fetchRequest)
            self.stores = self.stores.sorted(by: {$0.name! < $1.name!}) //sort the store name in alphabetical order
            self.storePicker.reloadAllComponents()
        } catch {
            
            //handle the error
            let error = error as NSError
            print("\(error)")
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        var item: Item!
        
        if itemToEdit == nil {
            
            item = Item(context: context)
        } else {
            
            item = itemToEdit
        }
        
        if let title = titleField.text {
            
            item.title = title
        }
        
        if let price = priceField.text {
            
            item.price = (price as NSString).doubleValue
        }
        
        if let details = detailsField.text {
            
            item.details = details
        }
        
        //current selection made at UIPickerView.  inComponent: 0 refers to the first and only column
        item.toStore = stores[storePicker.selectedRow(inComponent: 0)]
        
        //save to database
        ad.saveContext()
        
        //new syntax for popViewController.  Take us back to the main ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    //load existing item for editing
    func loadItemData() {
        
        if let item = itemToEdit {
            
            titleField.text = item.title
            priceField.text = "\(item.price)"
            detailsField.text = item.details
            
            if let store = item.toStore {
                
                var index = 0
                repeat {
                    
                    let s = stores[index]
                    if s.name == store.name {
                        
                        storePicker.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    index += 1
                } while (index < stores.count)
            }
        }
    }
}
