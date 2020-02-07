//
//  ShareViewController.swift
//  Spothawk
//
//  Created by user138340 on 7/12/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ShareViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var spotTable: UITableView!
    @IBOutlet weak var addSpot: UIButton!
    
    @IBOutlet weak var seg_spot: UISegmentedControl!
    var  spotbool = false
    
    //   var spots = [Spot]()
    var refArtists: DatabaseReference!
    var arrspot:NSMutableArray = NSMutableArray()
    var arrspotAll:NSMutableArray = NSMutableArray()
    var hud : MBProgressHUD = MBProgressHUD()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        Spinner.stop()
        
        self.spotTable.dataSource = self
        self.spotTable.rowHeight = 100
        self.spotTable.tableFooterView = UIView()

      //  AppState.sharedInstance.activeSpot.getSpots()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShareViewController.RefreshData(notification:)), name: Notification.Name("Spots"), object: nil)
        
     
    }
    
    @objc func RefreshData(notification: Notification) {
        // AppState.sharedInstance.activeSpot.getSpots()
        print(AppState.sharedInstance.spots.count)
        self.spotTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.sharedInstance.spots.count > 0 {
            navigationItem.rightBarButtonItem = editButtonItem
            self.editButtonItem.title = "Delete"
        }
        self.spotTable.reloadData()
        
        
        for i in 0..<AppState.sharedInstance.spots.count{
            let spot = AppState.sharedInstance.spots[i]
             AppState.sharedInstance.user.avg1 = AppState.sharedInstance.user.avg1 + (spot.hourlyPricing as NSString).integerValue
             AppState.sharedInstance.user.avg2 = AppState.sharedInstance.user.avg2 + (spot.dailyPricing as NSString).integerValue
             AppState.sharedInstance.user.avg3 = AppState.sharedInstance.user.avg3 + (spot.weeklyPricing as NSString).integerValue
             AppState.sharedInstance.user.avg4 =  AppState.sharedInstance.user.avg4 + (spot.monthlyPricing as NSString).integerValue
           
        }
        
        if AppState.sharedInstance.spots.count != 0 {
            AppState.sharedInstance.user.avg1 = AppState.sharedInstance.user.avg1/AppState.sharedInstance.spots.count
            AppState.sharedInstance.user.avg2  = AppState.sharedInstance.user.avg2/AppState.sharedInstance.spots.count
            AppState.sharedInstance.user.avg3 = AppState.sharedInstance.user.avg3/AppState.sharedInstance.spots.count
            AppState.sharedInstance.user.avg4 = AppState.sharedInstance.user.avg4/AppState.sharedInstance.spots.count
        }
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return AppState.sharedInstance.spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath) as? SpotTableViewCell
        let spot = AppState.sharedInstance.spots[indexPath.row]
         cell?.addressLabel.text = spot.address
        cell?.townCityZipLabel.text = spot.town + " " + spot.state + ", " + spot.zipCode
     // cell!.imageView?.sd_setImage(with: URL(string: spot.spotImage), placeholderImage: UIImage(named: "Placeholder"))
        cell!.spotImageView?.sd_setImage(with: URL(string: spot.spotImage), placeholderImage: UIImage(named: "Placeholder"))
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        spotTable.setEditing(editing, animated: animated)
        
        if(self.isEditing)
        {
            self.editButtonItem.title = "Done"
        }else
        {
            self.editButtonItem.title = "Delete"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            let spot_dict = AppState.sharedInstance.spots[indexPath.row]
            AppState.sharedInstance.activeSpot.Delete_Spots(spot_dict: spot_dict, index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
             
            tableView.reloadData()
           
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
     }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
    }
    
   //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            
        case "addSpotSegue":
            print("Add Spot")
            AppState.sharedInstance.activeSpot = Spot(address: "", town: "", state: "", zipCode: "", spotImage: "", description: "", monStartTime: "12:00 AM", monEndTime: "11:59 PM", tueStartTime: "12:00 AM", tueEndTime: "11:59 PM", wedStartTime: "12:00 AM", wedEndTime: "11:59 PM", thuStartTime: "12:00 AM", thuEndTime: "11:59 PM", friStartTime: "12:00 AM", friEndTime: "11:59 PM", satStartTime: "12:00 AM", satEndTime: "11:59 PM", sunStartTime: "12:00 AM", sunEndTime: "11:59 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "0", dailyPricing: "0", weeklyPricing: "0", monthlyPricing: "0", weeklyOn: true, monthlyOn: true, index: -1, approved: false, spotImages: UIImage.init(named: "emptySpot")!, spots_id: "", latitude: "0",longitude: "0", spottype: "", owner_id: "", Email:(UserDefaults.standard.value(forKey: "logindata") as! NSDictionary).value(forKey: "email") as? String ?? "", baseprice: "$ 5")!
         
            
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
            let activedict = AppState.sharedInstance.spots[indexPath.row]
        //  print(activedict.thuEndTime)
            
            AppState.sharedInstance.activeSpot = Spot(address: activedict.address, town: activedict.town, state: activedict.state, zipCode: activedict.zipCode, spotImage: activedict.spotImage, description: activedict.description, monStartTime: activedict.monStartTime, monEndTime: activedict.monEndTime, tueStartTime: activedict.tueStartTime, tueEndTime: activedict.tueEndTime, wedStartTime: activedict.wedStartTime, wedEndTime: activedict.wedEndTime, thuStartTime: activedict.thuStartTime, thuEndTime: activedict.thuEndTime, friStartTime: activedict.friStartTime, friEndTime: activedict.friEndTime, satStartTime: activedict.satStartTime, satEndTime:activedict.satEndTime, sunStartTime: activedict.sunStartTime, sunEndTime: activedict.sunEndTime, monOn: activedict.monOn, tueOn: activedict.tueOn, wedOn: activedict.wedOn, thuOn: activedict.thuOn, friOn: activedict.friOn, satOn: activedict.satOn, sunOn: activedict.sunOn, hourlyPricing: activedict.hourlyPricing, dailyPricing: activedict.dailyPricing, weeklyPricing: activedict.weeklyPricing, monthlyPricing: activedict.monthlyPricing, weeklyOn: activedict.weeklyOn, monthlyOn: activedict.monthlyOn, index: activedict.index, approved: activedict.approved, spotImages:activedict.spotImage1, spots_id: activedict.spot_id, latitude: activedict.latitude, longitude: activedict.longitude, spottype: activedict.spot_type, owner_id: activedict.owner_ids, Email: activedict.Email, baseprice: activedict.basePricing)!
          
            // AppState.sharedInstance.activeSpot = AppState.sharedInstance.spots[indexPath.row]
          //  AppState.sharedInstance.activeSpot.index = indexPath.row
           
        default:
            print("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    
    func progressBar(){
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.labelText = "Loading..."
    }
}

