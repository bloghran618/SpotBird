//
//  CarsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 6/2/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class CarsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var CarsTable: UITableView!
    @IBOutlet weak var AddCarButton: UIButton!
    
    var refArtists: DatabaseReference!
    var arr:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CarsTable.dataSource = self
      
        
        refArtists = Database.database().reference().child("Cars");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
             if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    if snapshotValue.count>0{
                        self.arr.removeAllObjects()
                        for (theKey, theValue) in snapshotValue {
                            print(theValue)
                            self.arr.add(theValue)
                        }
                    }
                    for i in 0..<self.arr.count {
                        let cardict = self.arr.object(at: i) as! NSDictionary
                        print(cardict)
                        if AppState.sharedInstance.user.cars.count == 0 {
                        AppState.sharedInstance.user.cars = [
                            Car(make:cardict.value(forKey: "make") as! String, model: cardict.value(forKey: "model") as! String, year: cardict.value(forKey: "year") as! String, carImage: cardict.value(forKey: "image") as! String, userid:cardict.value(forKey: "id") as! String, isDefault: cardict.value(forKey: "default") as! Bool)] as! [Car]
                           }
                     }
                    
                   
                    self.CarsTable.reloadData()
                    }
                }
           })
        
        self.CarsTable.rowHeight = 100
        if AppState.sharedInstance.user.cars.count != 0{
         navigationItem.rightBarButtonItem = editButtonItem
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.sharedInstance.user.cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as? CarsTableViewCell
        
        let car = AppState.sharedInstance.user.cars[indexPath.row]
        
        cell?.MakeModel.text = car.make + " "  + car.model
        cell?.YearLabel.text = car.year
       // cell?.imageView?.image = car.carImage
        cell?.imageView?.sd_setImage(with: URL(string: car.carImage!), placeholderImage: UIImage(named: "placeholder.png"))
        if car.isDefault! {
            cell?.Default.image = UIImage(named: "DefaultCar")
        }
        else {
            cell?.Default.image = UIImage(named: "white")
        }
        return cell!
    }
   
     override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        CarsTable.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let db_car = AppState.sharedInstance.user.cars[indexPath.row]
            let url = db_car.carImage!
            let start = url.index(url.startIndex, offsetBy: 80)
            let end = url.index(url.endIndex, offsetBy: -53)
            let range = start..<end
            let imgname = url[range]
            print(db_car.carImage)
            print(imgname)
            
            let pictureRef = Storage.storage().reference().child("car/\(imgname)")
            pictureRef.delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // File deleted successfully
                }
            }
            
            let ref = Database.database().reference().child("Cars").queryOrdered(byChild: "id").queryEqual(toValue : db_car.userid!)
            ref.observe(.value, with:{ (snapshot: DataSnapshot) in
                for snap in snapshot.children {
                    print(snap as! DataSnapshot)
                    print((snap as! DataSnapshot).key)
                    print((snap as! DataSnapshot).value)
                    
            let Db_dict = ((snap as! DataSnapshot).value) as! NSDictionary
             if  db_car.make == Db_dict.value(forKey: "make") as! String
                && db_car.model == Db_dict.value(forKey: "model") as! String && db_car.year == Db_dict.value(forKey: "year") as? String {
                    self.refArtists = Database.database().reference().child("Cars");
                    self.refArtists.child((snap as! DataSnapshot).key).setValue(nil)
                  }
                }
            })
            AppState.sharedInstance.user.cars.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            CarsTable.reloadData()
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CarsDefinitionViewController, let car = sourceViewController.car {
            
            if let selectedIndexPath = CarsTable.indexPathForSelectedRow {
                // Update an existing car
                AppState.sharedInstance.user.cars[selectedIndexPath.row] = car
                AppState.sharedInstance.user.manageOneDefaultCar(carIndex: selectedIndexPath.row)
                CarsTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add new car
                let newIndexPath = IndexPath(row: AppState.sharedInstance.user.cars.count, section: 0)
                AppState.sharedInstance.user.cars.append(car)
                AppState.sharedInstance.user.manageOneDefaultCar(carIndex: (AppState.sharedInstance.user.cars.count-1))
                CarsTable.insertRows(at: [newIndexPath], with: .automatic)
            }
            CarsTable.reloadData()
        }
    }
        
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddCar":
            print("Add Car")
        case "ShowDetail":
            print(" show detail")
            guard let carsDefinitionViewController = segue.destination as? CarsDefinitionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCarCell = sender as? CarsTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            
            guard let indexPath = CarsTable.indexPath(for: selectedCarCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedCar = AppState.sharedInstance.user.cars[indexPath.row]
            carsDefinitionViewController.car = selectedCar
            
        default:
            print("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    
}
