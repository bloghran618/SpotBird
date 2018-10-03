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
    //    var cars = [Car]()
    
    var refArtists: DatabaseReference!
    var arr:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CarsTable.dataSource = self
        
        //        if AppState.sharedInstance.user.cars.count == 0 {
        //            AppState.sharedInstance.user.cars = [
        //                Car(make: "Tesla", model: "Roadster", year: "2018", carImage: UIImage(named: "EmptyCar")!, isDefault: true)
        //                ] as! [Car]
        //        }
         refArtists = Database.database().reference().child("Cars");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let snapshotValue = snapshot.value as! NSDictionary
                    
                    print(snapshotValue.count)
                    
                    if snapshotValue.count>0{
                        self.arr.removeAllObjects()
                        for (theKey, theValue) in snapshotValue {
                            print(theValue)
                            self.arr.add(theValue)
                        }
                    }
                    
                    
                    
                    print(self.arr)
                    print(self.arr.count)
                    self.CarsTable.reloadData()
                    
                    
                }
            }
        })
        
        self.CarsTable.rowHeight = 100
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as? CarsTableViewCell
        
        let car = arr[indexPath.row] as! NSDictionary
        print(car)
        let makecar = car.value(forKey: "make") as! String
        let modelcar = car.value(forKey: "model") as! String
        let yearcar = car.value(forKey: "year") as! String
        let imagecar = car.value(forKey: "image") as! String
        let defaultcar = car.value(forKey: "default") as! Bool
        
        cell?.MakeModel.text = makecar + "  \(modelcar)"
        cell?.YearLabel.text = yearcar
        cell?.imageView?.sd_setImage(with: URL(string: imagecar), placeholderImage: UIImage(named: "placeholder.png"))
        
        if defaultcar == true {
            cell?.Default.image = UIImage(named: "DefaultCar")
        }
        else {
            cell?.Default.image = UIImage(named: "white")
        }
        
        
        
        //        let cars = ["id":"",
        //                    "make":self.Make.text!,
        //                    "model":self.Model.text!,
        //                    "year": self.Year.text!,
        //                    "image": fullURL
        //        ]
        
        //        cell?.MakeModel.text = car.make + " "  + car.model
        //        cell?.YearLabel.text = car.year
        //        cell?.imageView?.image = car.carImage
        //        if car.isDefault! {
        //            cell?.Default.image = UIImage(named: "DefaultCar")
        //        }
        //        else {
        //            cell?.Default.image = UIImage(named: "white")
        //        }
        return cell!
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        CarsTable.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //            // Delete the row from the data source
            //            AppState.sharedInstance.user.cars.remove(at: indexPath.row)
            //
            //            //            (carIndex: 0)
            
            //            refArtists = Database.database().reference().child("Cars");
            //            refArtists.child("-LNKqhdDoiOOLkXZsOwm").setValue(nil)
            
            let id = (arr.object(at: indexPath.row) as! NSDictionary).value(forKey: "id")
            let makes = (arr.object(at: indexPath.row) as! NSDictionary).value(forKey: "make") as! String
            let models = (arr.object(at: indexPath.row) as! NSDictionary).value(forKey: "model") as! String
            let years = (arr.object(at: indexPath.row) as! NSDictionary).value(forKey: "year") as! String
            let url = (arr.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String
            print(url)
            
            
            let start = url.index(url.startIndex, offsetBy: 80)
            let end = url.index(url.endIndex, offsetBy: -53)
            let range = start..<end
            let imgname = url[range]
            print(imgname)
            
            
            let pictureRef = Storage.storage().reference().child("car/\(imgname)")
            pictureRef.delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // File deleted successfully
                }
            }
            
            
            let ref = Database.database().reference().child("Cars").queryOrdered(byChild: "id").queryEqual(toValue : id)
            
            ref.observe(.value, with:{ (snapshot: DataSnapshot) in
                for snap in snapshot.children {
                    print(snap as! DataSnapshot)
                    print((snap as! DataSnapshot).key)
                    print((snap as! DataSnapshot).value)
                    
        let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    
                    
           if  makes == dict.value(forKey: "make") as! String
             && models == dict.value(forKey: "model") as! String && years == dict.value(forKey: "year") as! String {
                    
                    
                    self.refArtists = Database.database().reference().child("Cars");
                    self.refArtists.child((snap as! DataSnapshot).key).setValue(nil)
                    
                    
                }
                }
            })
            
            
            
            
            print(arr.object(at: indexPath.row))
            
            arr.removeObject(at: indexPath.row)
            
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
            
            // let selectedCar = AppState.sharedInstance.user.cars[indexPath.row]
            // carsDefinitionViewController.car = selectedCar
            
            carsDefinitionViewController.dict  = arr.object(at: indexPath.row) as! NSDictionary
            
        default:
            print("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    
}
