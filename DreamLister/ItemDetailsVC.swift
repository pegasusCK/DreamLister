//
//  ItemDetailsVC.swift
//  DreamLister
//
//  Created by Chihkao Yu on 6/19/17.
//  Copyright © 2017 Chihkao Yu. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var priceField: CustomTextField!
    @IBOutlet weak var detailsField: CustomTextField!
    @IBOutlet weak var thumbImg: UIImageView!
    
    var stores = [Store]()
    var itemTypes = [ItemType]()
    var itemToEdit: Item?
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //replace the title so the name of the source segue VC doesn't show up on the ItemDetailsVC/ItemDetailsVCNew
        if let topItem = self.navigationController?.navigationBar.topItem {
            
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        storePicker.delegate = self
        storePicker.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self

//        create hard-code data for Store picker
//
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

//      create hard-code data for ItemType picker
//
//        let iT1 = ItemType(context: context)
//        iT1.type = "Appliance"
//        let iT2 = ItemType(context: context)
//        iT2.type = "Computers"
//        let iT3 = ItemType(context: context)
//        iT3.type = "Auto"
//        let iT4 = ItemType(context: context)
//        iT4.type = "Household"
//        let iT5 = ItemType(context: context)
//        iT5.type = "Misc"
//        let iT6 = ItemType(context: context)
//        iT6.type = "Electronics"
//        
//        ad.saveContext()
        
        getStores()
        getItemType()
        
        if itemToEdit != nil {
            
            loadItemData()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //for single category picker column
        //
        //let store = stores[row]
        //return store.name
        
        if component == 0 {
            
            let store = stores[row]
            
            return store.name
        } else {
            
            let itemType = itemTypes[row]
            
            return itemType.type
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //for single category picker column
        //
        //return stores.count
        
        if component == 0 {
            
            return stores.count
        } else {
            
            return itemTypes.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
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
    
    func getItemType() {
        
        let fetchRequest: NSFetchRequest<ItemType> = ItemType.fetchRequest()
        
        do {
            self.itemTypes = try context.fetch(fetchRequest)
            self.itemTypes = self.itemTypes.sorted(by: {$0.type! < $1.type!}) //sort the store name in alphabetical order
            //self.storePicker.reloadAllComponents()
            
            print(itemTypes.count)
            for i in 0..<itemTypes.count {
                print("----------")
                print(itemTypes[i].type!)
            }
        } catch {
            
            //handle the error
            let error = error as NSError
            print("\(error)")
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        var item: Item!
        
        //add picture to the Item
        let picture = Image(context: context)
        picture.image = thumbImg.image
        
        //check to see if new item entry will need to be created or if the item will need to be loaded into ItemDetailsVC for editing
        if itemToEdit == nil {
            
            item = Item(context: context)
        } else {
            
            item = itemToEdit
        }
        
        if let title = titleField.text {
            
            item.title = title
        }
        
        //set picture
        item.toImage = picture
        
        if let price = priceField.text {
            
            item.price = (price as NSString).doubleValue
        }
        
        if let details = detailsField.text {
            
            item.details = details
        }
        
        //current selection made at UIPickerView.  inComponent: 0 refers to the first and only column
        item.toStore = stores[storePicker.selectedRow(inComponent: 0)]
        item.toItemType = itemTypes[storePicker.selectedRow(inComponent: 1)]
        
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
            thumbImg.image = item.toImage?.image as? UIImage
            
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
            
            if let itemType = item.toItemType {
                
                var count = 0
                repeat {
                    
                    let i = itemTypes[count]
                    if i.type == itemType.type {
                        
                        storePicker.selectRow(count, inComponent: 1, animated: false)
                        break;
                    }
                    count += 1
                } while (count < itemTypes.count)
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        
        if itemToEdit != nil {
            
            context.delete(itemToEdit!)
            ad.saveContext()
        }
        
        //pop back to the controller
        _ = navigationController?.popViewController(animated: true)
    }
    
    //set image in add-edit controller
    @IBAction func addImage(_ sender: UIButton) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            thumbImg.image = img
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
