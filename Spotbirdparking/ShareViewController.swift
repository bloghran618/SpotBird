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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spotTable.dataSource = self
        self.spotTable.rowHeight = 100
      // navigationItem.rightBarButtonItem = editButtonItem
     // Fatch DATABASE
        fetchdata()
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
        if spotbool == true{
            if editingStyle == .delete {
                let id = (arrspot.object(at: indexPath.row) as! NSDictionary).value(forKey: "id")
                let url = (arrspot.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String
                print(url)
                
                
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
                let ref = Database.database().reference().child("Spots").queryOrdered(byChild: "id").queryEqual(toValue : id)
                ref.observe(.value, with:{ (snapshot: DataSnapshot) in
                    for snap in snapshot.children {
                        print(snap as! DataSnapshot)
                        self.refArtists = Database.database().reference().child("Cars");
                        self.refArtists.child((snap as! DataSnapshot).key).setValue(nil)
                      }
                })
                
              // arrspot.removeObject(at: indexPath.row)
                AppState.sharedInstance.spots.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    
    func fetchdata() {
        refArtists = Database.database().reference().child("Spots");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    print(snapshotValue.count)
                    if snapshotValue.count>0{
                        self.arrspot.removeAllObjects()
                        self.arrspotAll.removeAllObjects()
                        for (theKey, theValue) in snapshotValue {
                            self.arrspotAll.add(theValue)
                            
                            let dict = theValue as! NSDictionary
                            if dict.value(forKey: "id") as! String  ==  AppState.sharedInstance.userid{
                                
                                self.arrspot.add(theValue)
                            }
                        }
                        if self.arrspot.count>0{
                            
                            for i in 0..<self.arrspot.count {
                                let spotdict = self.arrspot.object(at: i) as! NSDictionary
                                let Query = [Spot(address: spotdict.value(forKey: "address") as!
                                    String, town: spotdict.value(forKey: "city") as! String,
                                            state: spotdict.value(forKey: "state") as! String,
                                            zipCode:(spotdict.value(forKey: "zipcode") as? String)!,
                                            
                                            spotImage: spotdict.value(forKey: "image") as! String,
                                            description: spotdict.value(forKey: "description") as! String,
                                            
                                            monStartTime: spotdict.value(forKey: "monStartTime") as! String,
                                            monEndTime: spotdict.value(forKey: "monEndTime") as! String,
                                            tueStartTime:(spotdict.value(forKey: "tueStartTime") as? String)!,
                                            tueEndTime: spotdict.value(forKey: "tueEndTime") as! String,
                                            wedStartTime: spotdict.value(forKey: "wedStartTime") as! String,
                                            wedEndTime: spotdict.value(forKey: "wedEndTime") as! String,
                                            thuStartTime: spotdict.value(forKey: "thuStartTime") as! String,
                                            thuEndTime: spotdict.value(forKey: "tueEndTime") as! String,
                                            friStartTime: spotdict.value(forKey: "friStartTime") as! String,
                                            friEndTime: spotdict.value(forKey: "friEndTime") as! String,
                                            satStartTime: spotdict.value(forKey: "satStartTime") as! String,
                                            satEndTime: spotdict.value(forKey: "satEndTime") as! String,
                                            sunStartTime: spotdict.value(forKey: "sunStartTime") as! String,
                                            sunEndTime: spotdict.value(forKey: "sunEndTime") as! String,
                                            
                                            monOn: spotdict.value(forKey: "monswitch") as! Bool,
                                            tueOn:spotdict.value(forKey: "tueswitch") as! Bool,
                                            wedOn: spotdict.value(forKey: "wedswitch") as! Bool,
                                            thuOn: spotdict.value(forKey: "thuswitch") as! Bool,
                                            friOn: spotdict.value(forKey: "friswitch") as! Bool,
                                            satOn: spotdict.value(forKey: "satswitch") as! Bool,
                                            sunOn: spotdict.value(forKey: "sunswitch") as! Bool,
                                            
                                            hourlyPricing: spotdict.value(forKey: "hourlyPricing") as! String,
                                            dailyPricing: spotdict.value(forKey: "dailyPricing") as! String,
                                            weeklyPricing: spotdict.value(forKey: "weeklyPricing") as! String,
                                            monthlyPricing: spotdict.value(forKey: "monthlyPricing") as! String,
                                            
                                            weeklyOn: spotdict.value(forKey: "switch_weekly") as! Bool,
                                            monthlyOn: spotdict.value(forKey: "switch_monthly") as! Bool,
                                            index: -1,
                                            approved:false)]
                                  AppState.sharedInstance.spots = Query as! [Spot]
                               }
                        }
                        if AppState.sharedInstance.spots.count > 0 {
                           self.navigationItem.rightBarButtonItem = self.editButtonItem
                        }
                        
                        self.spotTable.reloadData()
                    }
                }
            }
        })
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            
        case "addSpotSegue":
            print("Add Spot")
            AppState.sharedInstance.activeSpot = Spot(address: "", town: "", state: "", zipCode: "", spotImage: "", description: "", monStartTime: "12:00 AM", monEndTime: "12:00 PM", tueStartTime: "12:00 AM", tueEndTime: "12:00 PM", wedStartTime: "12:00 AM", wedEndTime: "12:00 PM", thuStartTime: "12:00 AM", thuEndTime: "12:00 PM", friStartTime: "12:00 AM", friEndTime: "12:00 PM", satStartTime: "12:00 AM", satEndTime: "12:00 PM", sunStartTime: "12:00 AM", sunEndTime: "12:00 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "", dailyPricing: "", weeklyPricing: "", monthlyPricing: "", weeklyOn: true, monthlyOn: true, index: -1, approved: false)!
            
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
