//
//  CarsViewController.swift
//  LightPark
//
//  Created by Brian Loughran on 6/2/18.
//  Copyright © 2020 LightPark. All rights reserved.
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
       
        Spinner.stop()
        
        super.viewDidLoad()
        CarsTable.dataSource = self
        self.CarsTable.tableFooterView = UIView()
        self.CarsTable.rowHeight = 100
        
        AppState.sharedInstance.user.GetCar()
        
        if AppState.sharedInstance.user.cars.count != 0{
            navigationItem.rightBarButtonItem = editButtonItem
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(addTapped))
            CarsTable.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(CarsViewController.RefreshData(notification:)), name: Notification.Name("cars"), object: nil)
    }
    
   
    
    @objc func RefreshData(notification: Notification) {
        if AppState.sharedInstance.user.cars.count != 0{
            navigationItem.rightBarButtonItem = editButtonItem
            if(self.isEditing)
            {
                self.editButtonItem.title = "Done"
            }else
            {
                self.editButtonItem.title = "Delete"
            }
        }
        CarsTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.sharedInstance.user.cars.count
    }
    
    // Place data in cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as? CarsTableViewCell
         let car = AppState.sharedInstance.user.cars[indexPath.row]
        cell?.MakeModel.text = car.make + " "  + car.model
        cell?.YearLabel.text = car.year
        // cell?.imageView?.image = car.carImage
        
        print(car.carImage)
       // cell?.imageView?.sd_setImage(with: URL(string: car.carImage), placeholderImage: UIImage(named: "Placeholder"))
        cell?.ImageName.sd_setImage(with: URL(string: car.carImage), placeholderImage: UIImage(named: "Placeholder"))
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
        
        if(self.isEditing)
        {
            self.editButtonItem.title = "Done"
        }else
        {
            self.editButtonItem.title = "Delete"
        }
    }
    
    // Delete a car
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
    
            let db_car = AppState.sharedInstance.user.cars[indexPath.row]
            AppState.sharedInstance.user.Delete_car(car_dict: db_car, index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
                 
             CarsTable.reloadData()
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
                CarsTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add new car
                let newIndexPath = IndexPath(row: AppState.sharedInstance.user.cars.count, section: 0)
                AppState.sharedInstance.user.cars.append(car)
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


