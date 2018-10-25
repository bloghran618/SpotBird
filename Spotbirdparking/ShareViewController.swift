//
//  ShareViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 7/12/18.
//  Copyright © 2018 Spotbird. All rights reserved.
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
        self.spotTable.dataSource = self
        self.spotTable.rowHeight = 100
       AppState.sharedInstance.activeSpot.getSpots()
        
     }
    
    override func viewDidAppear(_ animated: Bool) {
     self.spotTable.reloadData()
        
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
        cell?.imageView?.sd_setImage(with: URL(string: spot.spotImage), placeholderImage: UIImage(named: "placeholder.png"))
        
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell!
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        spotTable.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
                
                  let spot_dict = AppState.sharedInstance.spots[indexPath.row]
                let url = spot_dict.spotImage
                
//                let id = (arrspot.object(at: indexPath.row) as! NSDictionary).value(forKey: "id")
//                let url = (arrspot.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String
//                print(url)
                
                let start = url.index(url.startIndex, offsetBy: 80)
                let end = url.index(url.endIndex, offsetBy: -53)
                let range = start..<end
                let imgname = url[range]
                print(imgname)
                
                
                let pictureRef = Storage.storage().reference().child("spot//\(imgname)")
                pictureRef.delete { error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // File deleted successfully
                    }
                }
                self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)

                refArtists.child("MySpots").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(spot_dict.spot_id)
                    print(snapshot)
                    print(snapshot as! DataSnapshot)
                    print((snapshot as! DataSnapshot).key)
                    print((snapshot as! DataSnapshot).value)

                    if snapshot.hasChild((spot_dict.spot_id)){
                        self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("MySpots")
                        self.refArtists.child(spot_dict.spot_id).setValue(nil)
                        
                        self.refArtists = Database.database().reference().child("All_Spots")
                        self.refArtists.child(spot_dict.spot_id).setValue(nil)
                    }else{
                        print("jewsasassasass")
                    }
                })
                
                
                
                AppState.sharedInstance.spots.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
            AppState.sharedInstance.activeSpot = Spot(address: "", town: "", state: "", zipCode: "", spotImage: "", description: "", monStartTime: "12:00 AM", monEndTime: "12:00 PM", tueStartTime: "12:00 AM", tueEndTime: "12:00 PM", wedStartTime: "12:00 AM", wedEndTime: "12:00 PM", thuStartTime: "12:00 AM", thuEndTime: "12:00 PM", friStartTime: "12:00 AM", friEndTime: "12:00 PM", satStartTime: "12:00 AM", satEndTime: "12:00 PM", sunStartTime: "12:00 AM", sunEndTime: "12:00 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "", dailyPricing: "", weeklyPricing: "", monthlyPricing: "", weeklyOn: true, monthlyOn: true, index: -1, approved: false, spotImages: UIImage.init(named: "emptySpot")!, spots_id: "")!
            
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
    func progressBar(){
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = "Loading..."
    }
}

