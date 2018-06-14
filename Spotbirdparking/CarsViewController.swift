//
//  CarsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 6/2/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class CarsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var CarsTable: UITableView!
    @IBOutlet weak var AddCarButton: UIButton!
    var cars = [Car]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CarsTable.dataSource = self
        
        if cars.count == 0 {
            cars = [
                Car(make: "Tesla", model: "Roadster", year: "2018", carImage: UIImage(named: "EmptyCar")!, isDefault: true)
                ] as! [Car]
        }
        self.CarsTable.rowHeight = 100
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as? CarsTableViewCell
        
        let car = cars[indexPath.row]
        
        cell?.MakeModel.text = car.make + " "  + car.model
        cell?.YearLabel.text = car.year
        cell?.imageView?.image = car.carImage
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
            // Delete the row from the data source
            cars.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
                cars[selectedIndexPath.row] = car
                manageOneDefaultCar(carIndex: selectedIndexPath.row)
                CarsTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add new car
                let newIndexPath = IndexPath(row: cars.count, section: 0)
                cars.append(car)
                manageOneDefaultCar(carIndex: (cars.count-1))
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
            
            let selectedCar = cars[indexPath.row]
            carsDefinitionViewController.car = selectedCar
            
        default:
            print("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    private func manageOneDefaultCar(carIndex: Int) {
        print("Managing defaults...")
        print("See row \(carIndex)")
        if cars[carIndex].isDefault == true {
            for eachCar in cars {
                eachCar.isDefault = false
            }
            cars[carIndex].isDefault = true
        }
        return
    }
}
