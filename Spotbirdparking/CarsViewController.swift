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
    var key:NSMutableArray = NSMutableArray()
    var car: Car?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CarsTable.dataSource = self
        self.CarsTable.rowHeight = 100
         AppState.sharedInstance.user.GetCar()
        if AppState.sharedInstance.user.cars.count != 0{
            navigationItem.rightBarButtonItem = editButtonItem
            CarsTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CarsTable.reloadData()
        
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
        cell?.imageView?.sd_setImage(with: URL(string: car.carImage), placeholderImage: UIImage(named: "placeholder.png"))
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
            print(db_car.car_uid)
            let url = db_car.carImage
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
            
            self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
            
            refArtists.child("Cars").observeSingleEvent(of: .value, with: { (snapshot) in
                print(self.car?.car_uid)
                print(snapshot)
                print(snapshot as! DataSnapshot)
                print((snapshot as! DataSnapshot).key)
                print((snapshot as! DataSnapshot).value)
                
                if snapshot.hasChild((db_car.car_uid)!){
                    self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars")
                    self.refArtists.child(db_car.car_uid!).setValue(nil)
                }else{
                    print("jewsasassasass")
                }
            })
            
            AppState.sharedInstance.user.cars.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            CarsTable.reloadData()
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
            let carsDefinitionViewController = segue.destination as? CarsDefinitionViewController
            carsDefinitionViewController?.add = "new"
            
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


