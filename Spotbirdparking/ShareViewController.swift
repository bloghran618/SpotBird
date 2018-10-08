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
    
    var spots = [Spot]()
    
    var refArtists: DatabaseReference!
    var arrspot:NSMutableArray = NSMutableArray()
    
    var arrspotAll:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spotTable.dataSource = self
        self.spotTable.rowHeight = 100
        
        //  navigationItem.rightBarButtonItem = editButtonItem
        seg_spot.selectedSegmentIndex = 1
        
        //
        //        AppState.sharedInstance.spots = spots
        
        //        AppState.sharedInstance.spots = [Spot(), Spot()]
        
        // Do any additional setup after loading the view.
        
        spotTable.allowsSelection = false
     
        fetchdata()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func seg_spotdata(_ sender: Any) {
        switch seg_spot.selectedSegmentIndex
        {
        case 0:
            NSLog("my selected")
            spotbool = true
            arrspot.removeAllObjects()
            for i in 0..<arrspotAll.count{
                if AppState.sharedInstance.userid == (arrspotAll.object(at: i) as! NSDictionary).value(forKey: "id") as! String
                {
                    arrspot.add(arrspotAll.object(at: i))
                }
            }
            
            spotTable.allowsSelection = true
            navigationItem.rightBarButtonItem = editButtonItem
            print(arrspot)
            spotTable.reloadData()
            
            
            
            
        case 1:
            NSLog("all selected")
            spotbool = false
            arrspot.removeAllObjects()
            for i in 0..<arrspotAll.count{
                if AppState.sharedInstance.userid != (arrspotAll.object(at: i) as! NSDictionary).value(forKey: "id") as! String
                {
                    arrspot.add(arrspotAll.object(at: i))
                }
            }
            spotTable.allowsSelection = false
            navigationItem.rightBarButtonItem = nil
            print(arrspot)
            spotTable.reloadData()
            
            
        default:
            break;
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrspot.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath) as? SpotTableViewCell
        let spot = arrspot[indexPath.row] as!  NSDictionary
        print(spot)
        
        let city = spot.value(forKey: "city") as! String
        let state = spot.value(forKey: "state") as! String
        let zipcode = spot.value(forKey: "zipcode") as! String
        let imagespot = spot.value(forKey: "image") as! String
        let address = spot.value(forKey: "address") as? String
        
        
        
        cell?.addressLabel.text = address
        cell?.townCityZipLabel.text = city + "  \(state)  \(zipcode)"
         cell?.imageView?.sd_setImage(with: URL(string: imagespot), placeholderImage: UIImage(named: "placeholder.png"))
        
        
        if(spotbool == false)
        {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        else
        {
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        
        //        let spot = AppState.sharedInstance.spots[indexPath.row]
        //        cell?.addressLabel.text = spot.address
        //        cell?.townCityZipLabel.text = spot.town + " " + spot.state + ", " + spot.zipCode
        //        cell?.imageView!.image = spot.spotImage
        
        return cell!
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if spotbool == true{
         spotTable.setEditing(editing, animated: animated)
        }
        else{
         spotTable.setEditing(false, animated: false)
        }
      }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if spotbool == true{
         if editingStyle == .delete {
            // Delete the row from the data source
            //   AppState.sharedInstance.spots.remove(at: indexPath.row)
            
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
            
            
            
            arrspot.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if spotbool == true {
        return true
        }else{
            return false
        }
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "addressSegue" {
    //            AppState.sharedInstance.activeSpot = Spot()
    //        }
    //    }
    
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
                            print(theValue)
                            self.arrspotAll.add(theValue)
                            
                            let dict = theValue as! NSDictionary
                            if dict.value(forKey: "id") as! String  !=  AppState.sharedInstance.userid{
                                
                                self.arrspot.add(theValue)
                            }
                        }
                        print(self.arrspot)
                        print(self.arrspot.count)
                        //    self.arrspotAll = self.arrspot.mutableCopy() as! NSMutableArray
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
            //  AppState.sharedInstance.activeSpot = Spot()
            AppState.sharedInstance.dict_spot.removeAllObjects()
            
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
            
            //            AppState.sharedInstance.activeSpot = AppState.sharedInstance.spots[indexPath.row]
            //            AppState.sharedInstance.activeSpot.index = indexPath.row
            AppState.sharedInstance.dict_spot = arrspot.object(at: indexPath.row) as! NSMutableDictionary
            
        default:
            print("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    
}
