//
//  ShareViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 7/12/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var spotTable: UITableView!
    @IBOutlet weak var addSpot: UIButton!
    var spots = [Spot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spotTable.dataSource = self
        self.spotTable.rowHeight = 100
        
        navigationItem.rightBarButtonItem = editButtonItem

//        let spots = [Spot(address: "42 Ardmore Rd", town: "West Hartford", state: "CT", zipCode: "06119", spotImage: UIImage.init(named: "empytSpot")!, description: "This is a spop", monStartTime: "12:00 AM", monEndTime: "12:00 Am", tueStartTime: "12:00 AM", tueEndTime: "12:00 AM", wedStartTime: "12:00 AM", wedEndTime: "12:00 AM", thuStartTime: "12:00 AM", thuEndTime: "12:00 AM", friStartTime: "12:00 AM", friEndTime: "12:00 AM", satStartTime: "12:00 AM", satEndTime: "12:00 AM", sunStartTime: "12:00 AM", sunEndTime: "12:00 AM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1.00", dailyPricing: "1.00", weeklyPricing: "1.00", monthlyPricing: "1.00", weeklyOn: true, monthlyOn: true)]
//
//        AppState.sharedInstance.spots = spots
        
//        AppState.sharedInstance.spots = [Spot(), Spot()]

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.spotTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(AppState.sharedInstance.spots.count)
        return AppState.sharedInstance.spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath) as? SpotTableViewCell
        
        let spot = AppState.sharedInstance.spots[indexPath.row]
        
        cell?.addressLabel.text = spot.address
        cell?.townCityZipLabel.text = spot.town + " " + spot.state + ", " + spot.zipCode
        cell?.imageView!.image = spot.spotImage
        
        return cell!
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        spotTable.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            AppState.sharedInstance.spots.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addressSegue" {
//            AppState.sharedInstance.activeSpot = Spot()
//        }
//    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            
        case "addSpotSegue":
            print("Add Spot")
            AppState.sharedInstance.activeSpot = Spot()
            
        case "editSpotSegue":
            print("Edit Spot")
            guard let addressViewController = segue.destination as? AddressViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedSpotCell = sender as? SpotTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            
            guard let indexPath = spotTable.indexPath(for: selectedSpotCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            AppState.sharedInstance.activeSpot = AppState.sharedInstance.spots[indexPath.row]
            AppState.sharedInstance.activeSpot.index = indexPath.row
            
        default:
            print("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }

}
