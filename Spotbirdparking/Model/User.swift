//
//  User.swift
//
//
//  Created by user138340 on 8/27/18.
//

import Foundation
import UIKit
import Firebase
import Alamofire

class User {
    
    var firstName: String
    var lastName: String
    var profileImage: String
    var cars: [Car]
    var New_img = UIImageView()
    var imgname = ""
    var accounttoken = String()
    var customertoken = String()
    var reservations: [Reservation]
    var myReservations = NSMutableArray()
    
    var avg1 = Int()
    var avg2 = Int()
    var avg3 = Int()
    var avg4 = Int()
    var totalBalance = ""
    var lifeBalance = ""
    var reservationsDownloaded = false
    var temporary_paymentIntent_id = ""
    var refArtists: DatabaseReference!
   
    init?(firstName: String, lastName: String, profileImage: String, cars: [Car], reservations: [Reservation]) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
        self.cars = cars
        self.reservations = reservations
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.profileImage = ""
        self.cars = []
        self.reservations = []
    }
    
    public func manageOneDefaultCar(carIndex: Int) {
        //make every car defualt to false except carIndex specified
        for eachCar in self.cars {
            if eachCar.isDefault == true {
                let imagURL = URL(string: eachCar.carImage)
                let imagData = try! Data(contentsOf: imagURL!)
                let image = UIImage(data: imagData)
                AppState.sharedInstance.user.SetCar(car_uid: (eachCar.car_uid)!, make: eachCar.make, Model: eachCar.model, year: eachCar.year!, setbool: false, image: image!, strurl: eachCar.carImage)
            }
        }
        let imagURL = URL(string: self.cars[carIndex].carImage)
        let imagData = try! Data(contentsOf: imagURL!)
        let image = UIImage(data: imagData)
        AppState.sharedInstance.user.SetCar(car_uid: (self.cars[carIndex].car_uid)!, make: self.cars[carIndex].make, Model: self.cars[carIndex].model, year: self.cars[carIndex].year!, setbool: true, image: image!, strurl: self.cars[carIndex].carImage)
        
     }
    
    // get the Car object of the default car
    public func getDefaultCar() -> Car {
        for car in self.cars {
            if(car.isDefault!) {
                return car
            }
        }
        // if algorithm cannot find default, return first car
        return self.cars[0]
    }
    
    public func testDefaultCar() -> Int {
        var numDefaults = 0
        for eachCar in self.cars {
            numDefaults += 1
        }
        return numDefaults
    }

    // Get database to car
    public func Get_UserProfile() {
        var refArtists: DatabaseReference!
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    
                    
                    let logindata = [
                        "fname":dict.value(forKey: "fname") as! String,
                        "id":dict.value(forKey: "id") as! String,
                        "image":dict.value(forKey: "image") as! String,
                        "lname":dict.value(forKey: "lname") as! String,
                        "uname":dict.value(forKey: "uname") as! String,
                        "email":dict.value(forKey: "email") as! String,
                        "customerToken":dict.value(forKey: "customerToken") as! String,
                        "accountToken":dict.value(forKey: "accountToken") as! String,
                        ]
                    
                    
                    UserDefaults.standard.setValue(logindata, forKey: "logindata")
                    UserDefaults.standard.synchronize()
                    let data_login = UserDefaults.standard.value(forKey: "logindata") as! NSDictionary
                    print(data_login)
                    
                    AppState.sharedInstance.user.firstName = (data_login.value(forKey: "fname") as? String)!
                    AppState.sharedInstance.user.lastName = (data_login.value(forKey: "lname") as? String)!
                    AppState.sharedInstance.user.profileImage = (dict.value(forKey: "image") as? String)!
                    
                    if AppState.sharedInstance.user.profileImage != "" {
                        let strurl = AppState.sharedInstance.user.profileImage
                        let startIndex = strurl.index(strurl.startIndex, offsetBy: 81)
                        let endIndex = strurl.index(strurl.startIndex, offsetBy: 85)
                        AppState.sharedInstance.user.imgname =  String(strurl[startIndex...endIndex])
                    }
                    
                }
            }
        })
    }
    
    // Set database to car
    public func Set_UserProfile(change:String) {
        Spinner.start()
        var imageReference: StorageReference {
            return Storage.storage().reference().child("User")
        }
        
        if change == "nil"{
            let str = "User/" + AppState.sharedInstance.userid
            let ref = Database.database().reference().child(str)
            print(AppState.sharedInstance.user.firstName)
            print(AppState.sharedInstance.user.lastName)
            
            ref.updateChildValues([
                "fname":AppState.sharedInstance.user.firstName,
                "lname":AppState.sharedInstance.user.lastName,
                ]){
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                        Spinner.stop()
                        
                    } else {
                        print("Data saved successfully!")
                        self.Get_UserProfile()  //
                        Spinner.stop()
                    }
            }
        }
        else if change == "same"
        {
            let pictureRef = Storage.storage().reference().child("User").child(AppState.sharedInstance.userid).child(imgname)
            pictureRef.delete { error in
                if let error = error {
                } else {
                    guard let imageData = UIImageJPEGRepresentation(self.New_img.image!, 0.5) else { return }
                    let uploadImageRef = imageReference.child(self.randomStringWithLength(length: 5) as String)
                    
                    let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                        print("UPLOAD TASK FINISHED")
                        print(metadata ?? "NO METADATA")
                        print(error ?? "NO ERROR")
                        
                        uploadImageRef.downloadURL(completion: { (url, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            if let url = url?.absoluteString {
                                let fullURL = url
                                print(fullURL)
                                
                                let str = "User/" + AppState.sharedInstance.userid
                                print(str)
                                let ref = Database.database().reference().child(str)
                                
                                ref.updateChildValues([
                                    "fname":AppState.sharedInstance.user.firstName,
                                    "lname":AppState.sharedInstance.user.lastName,
                                    "image":fullURL
                                ]){
                                    (error:Error?, ref:DatabaseReference) in
                                    if let error = error {
                                        print("Data could not be saved: \(error).")
                                        Spinner.stop()
                                        
                                    } else {
                                        print("Data saved successfully!")
                                         self.Get_UserProfile()  //
                                        Spinner.stop()
                                    }
                                }
                            }
                        })
                    }
                    uploadTask.observe(.progress) { (snapshot) in
                        print(snapshot.progress ?? "NO MORE PROGRESS")
                    }
                }
            }
            
        }
        else
        {
            //   let pictureRef = Storage.storage().reference().child("User/\(imgname)")
            
            guard let imageData = UIImageJPEGRepresentation(New_img.image!, 0.5) else { return }
            let uploadImageRef = imageReference.child(String(imgname))
            
            let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                uploadImageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let url = url?.absoluteString {
                        let fullURL = url
                        print(fullURL)
                        
                        let str = "User/" + AppState.sharedInstance.userid
                        print(str)
                        let ref = Database.database().reference().child(str)
                        
                        ref.updateChildValues([
                            "fname":AppState.sharedInstance.user.firstName,
                            "lname":AppState.sharedInstance.user.lastName,
                            "image":fullURL
                        ]){
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                print("Data could not be saved: \(error).")
                                Spinner.stop()
                                
                            } else {
                                print("Data saved successfully!")
                                 self.Get_UserProfile()  //
                                Spinner.stop()
                            }
                        }
                    }
                })
            }
            uploadTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "NO MORE PROGRESS")
            }
            
            
        }
    }
    
    // Get database to car
    public func GetCar() {
        print("Cars: \(AppState.sharedInstance.user.cars)")
        print("Start getCar()")
        
     var refArtists: DatabaseReference!
        refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars")
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                AppState.sharedInstance.user.cars.removeAll()
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    AppState.sharedInstance.user.cars.append(Car(make: snapshotValue.value(forKey: "make") as! String, model: snapshotValue.value(forKey: "model") as! String, year: snapshotValue.value(forKey: "year") as! String, carImage: snapshotValue.value(forKey: "image") as! String, isDefault: snapshotValue.value(forKey: "default") as! Bool,car_id:(artists as! DataSnapshot).key)!)
                    
                }
                print("Stop Spinner 16")
                Spinner.stop()
                NotificationCenter.default.post(name: Notification.Name("cars"), object: nil)
            }
        })
        print("Cars: \(AppState.sharedInstance.user.cars)")
    }
    
    
    // Set database to car
  func SetCar(car_uid :String,make:String,Model:String,year:String,setbool:Bool,image:UIImage,strurl:String) {
   
       Spinner.start()
    
        if car_uid == "" {
            self.addnewcar(car_uid :car_uid,make:make,Model:Model,year:year,setbool:setbool,carimage:image)
        }else {
            var refArtists: DatabaseReference!
            
            refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
            
            refArtists.child("Cars").observeSingleEvent(of: .value, with: { (snapshot) in
                print(car_uid)
                print(snapshot)
                
                if snapshot.hasChild(car_uid){
                    //Update CAr
                    self.Update_car(car_uid: car_uid, make: make, Model: Model, year: year, setbool: setbool, carimage: image, url: strurl)
                }else{
                    // Add New CAr
        self.addnewcar(car_uid :car_uid,make:make,Model:Model,year:year,setbool:setbool,carimage:image)
                }
            })
        }
     }
    
    //Update CAr
    func Update_car(car_uid :String,make:String,Model:String,year:String,setbool:Bool,carimage:UIImage,url:String)
    {
        var refArtists: DatabaseReference!
        print(url)
        let startIndex = url.index((url.startIndex), offsetBy: 80)
        let endIndex = url.index((url.startIndex), offsetBy: 84)
        let imgname =  String(url[startIndex...endIndex])
        print(imgname)
        
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("car")
        }
        
        guard let imageData = UIImageJPEGRepresentation(carimage, 0.5) else { return }
        let uploadImageRef = imageReference.child(String(imgname))
        
        let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
            print("UPLOAD TASK FINISHED")
            print(metadata ?? "NO METADATA")
            print(error ?? "NO ERROR")
            
            uploadImageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let url = url?.absoluteString {
                    let fullURL = url
                    print(fullURL)
                    
    let ref = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars").child(car_uid)
                    
                    ref.updateChildValues([
                        "make":make,
                        "model":Model,
                        "year": year,
                        "image": fullURL,
                        "default": setbool]){
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                print("Data could not be Update: \(error).")
                          
                             } else {
                                print("Data Update successfully!")
                                self.GetCar()
                          
                              }
                    }
                }
            })
        }
    }
    
    // Add New CAr
    func addnewcar(car_uid :String,make:String,Model:String,year:String,setbool:Bool,carimage:UIImage)
    {
        
        var refArtists: DatabaseReference!
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("car")
        }
        
        // guard let image = carimage else { return }
        guard let imageData = UIImageJPEGRepresentation(carimage, 0.5) else { return }
        print("***** Compressed Size \(imageData.description) **** ")
        let uploadImageRef = imageReference.child(randomStringWithLength(length: 5) as String)
        let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
            print("UPLOAD TASK FINISHED")
            print(metadata ?? "NO METADATA")
            print(error ?? "NO ERROR")
            
            uploadImageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let url = url?.absoluteString {
                    let fullURL = url
                    print(fullURL)
                    
                    refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars");
                    
                    let key = refArtists.childByAutoId().key
                    
                    let cars = [  "make":make,
                                  "model":Model,
                                  "year": year,
                                  "image": fullURL,
                                  "default": setbool
                        ] as [String : Any]
                    
                    refArtists.child(key!).setValue(cars){
                        (error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            print("Data could not be saved: \(error).")
                            print("Stop Spinner 17")
                            Spinner.stop()
                        
                        } else {
                            print("Data saved successfully!")
                            self.GetCar()
                                    //  Spinner.stop()
                         }
                    }
                  }
              })
         }
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress ?? "NO MORE PROGRESS")
        }
        uploadTask.resume()
    }
    
    // Delete a car
    func Delete_car(car_dict :Car,index:Int)
    {
        var refArtists: DatabaseReference!
        print(car_dict)
        
        let url = car_dict.carImage
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
        
        refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        
        refArtists.child("Cars").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild((car_dict.car_uid)!){
                refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars")
               refArtists.child(car_dict.car_uid!).setValue(nil)
            }else{
                print("jewsasassasass")
            }
        })
        
        AppState.sharedInstance.user.cars.remove(at: index)
        
    }
    
    func randomStringWithLength(length: Int) -> NSString {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: length)
        
        for i in 0..<length {
            let len = UInt32(characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        return randomString
    }
    
    
    // Set accountToken token
    func setaccountToken(accountToken:String)  {
        self.accounttoken = accountToken
       refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        refArtists.updateChildValues([
            "accountToken":accountToken
            ])
    
    }
    
    // Set customerToken token
    func setcustomerToken(customerToken:String)  {
        self.customertoken = customerToken
        refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        refArtists.updateChildValues([
            "customerToken":customerToken
            ])
        
    }
    
    // getaccountToken
    func getaccountToken(completion: @escaping (_ keys: String) -> Void) {
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    print(dict)
                    if let val = dict["accountToken"] {
                     completion(dict.value(forKey: "accountToken") as! String)
                    }
                }
            }
        })
    }
    
    // getcustomerToken
    func getcustomerToken(completion: @escaping (_ keys: String) -> Void) {
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    print(dict)
                    if let val = dict["customerToken"] {
                        completion(dict.value(forKey: "customerToken") as! String)
                    }
                }
            }
        })
    } 
    
    // add a new reservation to this User() object
    func addReservation(reservation: Reservation) {
        // add reservation to current User() object
//        self.reservations.append(reservation)
        
        print("Starting addReservation")
        
        // Set reference to active user in firebase
        let ref = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        
        // create dictionary to save
        let res =  ["startDateTime":reservation.startDateTime,
                    "endDateTime":reservation.endDateTime,
                    "parkOrRent": reservation.parkOrRent,
                    "price": reservation.price,
                    "spotID": reservation.spot.spot_id,
                    "parkerID": reservation.parkerID,
                    "carID": reservation.car.car_uid,
                    "ownerID": reservation.ownerID,
                    "paymentIntent_id": reservation.paymentIntent_id
            ] as [String : Any]
        
        // create random ID for reservation to be under
        let key = ref.childByAutoId().key
        
        print("res: \(res)")
        print("key: \(key)")
        
        // add the reservation to the database
        ref.child("Reservations").child(key!).setValue(res){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Parker Data could not be saved: \(error).")
            } else {
                print("Parker Data saved successfully!")
                AppState.sharedInstance.user.getReservations() { message in
                    print(message)
                }
            }
        }
    }
    
    // add a new reservation to a User() object from the database
    func addReservationToUser(reservation: Reservation) {
        // Set reference to spot owner User() in firebase
        let ref = Database.database().reference().child("User").child(reservation.spot.owner_ids)
        
        // create dictionary to save
        let res =  ["startDateTime":reservation.startDateTime,
                    "endDateTime":reservation.endDateTime,
                    "parkOrRent": reservation.parkOrRent,
                    "price": reservation.price,
                    "spotID": reservation.spot.spot_id,
                    "parkerID": reservation.parkerID,
                    "carID": reservation.car.car_uid,
                    "ownerID": reservation.ownerID,
                    "paymentIntent_id": reservation.paymentIntent_id
            ] as [String : Any]
        
        // create random ID for reservation to be under
        let key = ref.childByAutoId().key
        
        // add the reservation to the database
        ref.child("Reservations").child(key!).setValue(res){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Spot Owner Data could not be saved: \(error).")
            } else {
                print("Spot Owner Data saved successfully!")
            }
        }
    }
    
    // delete any reservation older than 2 months from the database
    func cleanOldReservations(completionHandler: @escaping (_ message: String) -> ()) {
        
        // set database reference to User() in the database
        let ref = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        
        // formatters and calendar setup
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd hh:mm"
        formatter.timeZone = TimeZone.current
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        // loop over each reservation in database reference
        ref.child("Reservations").observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let reservationDict = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    
                    // check if the res is more than 2 months old
                    let endDate = Reservation.stringToDate(string: reservationDict["endDateTime"] as! String)
                    let twoMonthsFromEnd = calendar.date(byAdding: .month, value: 2, to: endDate)
                    if (twoMonthsFromEnd! < Date()) {
                        print("should remove this reservation ending on: \(Reservation.dateToString(date: endDate))) at: \((artists as! DataSnapshot).key)")
                        let rem = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Reservations").child("\(artists.key)")
                        rem.removeValue()
                    }
                    else {
                        print("Should just leave this reservatoin")
                    }
                }
                completionHandler("deletion complete")
            }
        })
    }
    
    // get the list of reservations for a user
    func getReservations(completionHandler: @escaping (_ message: String) -> ()) {

        // empty any current reservations
        print("Current thread in \(#function) is \(Thread.current)")
        print("!!!!!!!! WE ARE GETTING THE RESERVATIONS !!!!!!!!!!!!!!!")
        print("Reservations: \(AppState.sharedInstance.user.reservations)")
        print("#: \(AppState.sharedInstance.user.reservations.count)")
        AppState.sharedInstance.user.reservations.removeAll()

        print("Get all the reservations")
        let user_id = AppState.sharedInstance.userid

        // set database reference to User() in the database
        let ref = Database.database().reference().child("User").child(user_id)
        //variable to see if there are reservations or not
        var reservation_check = false

        //checking to see if there are any reservations if case there are none
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            for dict in value{
                let key =  dict.key as! String
                if key == "Reservations" {
                    print("True at: " + key)
                    reservation_check = true
                }
            }
            if reservation_check == false {
                print("No reservations")
//                self.reservationsDownloaded = true
                completionHandler("there are no reservations")
            }

        }) { (error) in
            print(error.localizedDescription)
        }

        // loop over each reservation in database reference
        ref.child("Reservations").observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let reservationDict = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary

                    // get the parking Car() object
                    let userID = reservationDict["parkerID"] as! String
                    let carID = reservationDict["carID"] as! String
                    print("Parker ID: \(userID)")
                    print("Car ID: \(carID)")
                    self.carAtPath(carUser: userID, carID: carID) { (reservationCar) in
                        print("ReservationCar Make and year: \(reservationCar.make), \(reservationCar.year)")
                        
                        // get parking Spot() object
                        let spotID = reservationDict["spotID"] as! String
                        let ownerID = reservationDict["ownerID"] as! String
                        self.spotAtPath(userID: ownerID, spotID: spotID)
                        { (reservationSpot) in
                            //                            print("Spot address: \(reservationSpot.address)")
                            
                            // create Reservation() object
                            var dbReservation = Reservation(
                                startDateTime: reservationDict["startDateTime"] as! String,
                                endDateTime: reservationDict["endDateTime"] as! String,
                                parkOrRent: reservationDict["parkOrRent"] as! String,
                                spot: reservationSpot,
                                parkerID: reservationDict["parkerID"] as! String,
                                car: reservationCar,
                                ownerID: reservationDict["ownerID"] as! String,
                                paymentIntent_id: reservationDict["paymentIntent_id"] as! String)
                            
                            print("Reservation start: \(dbReservation!.startDateTime)")
                            
                            // make sure there are no doubles
                            if !self.reservationInReservations(res: dbReservation!, reservations: AppState.sharedInstance.user.reservations) {
                                // add reservation
                                AppState.sharedInstance.user.reservations.append(dbReservation!)
                                print("Reservation added")
                                print("# reservations: \(AppState.sharedInstance.user.reservations.count)")
                            }
                            else {
                                print("This reservation is a duplicate")
                            }
                        }
                    }
                    
                }
                completionHandler("End Function")
            }
            else {
                print("No reservations")
            }

            //Spinner.stop()
        })
        //Spinner.stop()
    }
    
//    func getReservationsOfCurrentUser(completionHandler: @escaping (_ message: String) -> ()) {
//        Spinner.start()
//        // empty any current reservations
//        print("!!!!!!!! WE ARE GETTING THE RESERVATIONS !!!!!!!!!!!!!!!")
//        AppState.sharedInstance.user.myReservations.removeAllObjects()
//        print("#: \(AppState.sharedInstance.user.myReservations.count)")
//        print("Get all the reservations")
//        let user_id = AppState.sharedInstance.userid
//        
//        // set database reference to User() reservations in the database
//        let ref = Database.database().reference().child("User").child(user_id).child("Reservations")
//        
//        // loop over each reservation in database reference
//        ref.observe(DataEventType.value, with: { (snapshot) in
//            if snapshot.childrenCount > 0 {
//                for artists in snapshot.children.allObjects as! [DataSnapshot] {
//                    let reservationDict = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
//                    print("Reservation Dict: \(reservationDict)")
//                    AppState.sharedInstance.user.myReservations.add(reservationDict)
//                }
//                completionHandler("COMPLETED... BOIII")
//            }
//            else {
//                print("No reservations")
//            }
//            //Spinner.stop()
//        })
//        print("Stop Spinner 18")
//        Spinner.stop()
//    }
    
    // check if a reservation matches one already in a list of reservations (ignore duplicates
    public func reservationInReservations(res: Reservation, reservations: [Reservation]) -> Bool {
        var isInReservations = false
        for reservation in reservations {
            // check if the reservations match
            if(
                res.startDateTime == reservation.startDateTime &&
                res.endDateTime == reservation.endDateTime &&
                res.parkOrRent == reservation.parkOrRent &&
                res.spot.address == reservation.spot.address &&
                res.parkerID == reservation.parkerID &&
                res.car.make == reservation.car.make &&
                res.car.model == reservation.car.model &&
                res.car.year == reservation.car.year &&
                res.ownerID == reservation.ownerID
                ) {
                isInReservations = true
            }
        }
        return isInReservations
    }
    
    // get the times that the user has reserved (to check if conflicting reservation)
    public func getReservationTimesForUser(spotUser: String, completionHandler: @escaping (_ timesList: [[String: String]]) -> ()) {
        
        print("Start getting reservation times for user")
        
        // set the reference to the users reservation list
        let ref = Database.database().reference().child("User").child(spotUser).child("Reservations")
        
        print("Created ref")
        
        // create empty list of times dictionary
        var reservationTimesList: [[String:String]] = []
        
        // loop over each reservation in database reference
        ref.observe(DataEventType.value, with: { (snapshot) in
            print("snapshot created")
            if snapshot.childrenCount > 0 {
                print("more than one value in snapshot")
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let reservationDict = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    
                    // each iteration saved to dictionary called snapshotValue
//                    print("Reservation Dict: \(reservationDict)")
                    
                    // create a dictionary containing the start and end time of the reservation
                    let timesDict = ["start": reservationDict["startDateTime"] as! String,
                                     "end": reservationDict["endDateTime"] as! String,
                                     "spotID": reservationDict["spotID"] as! String]
//                    print("Times Dict: \(timesDict)")
                    
                    // add the timesDict to the list of times dictionaries
                    reservationTimesList.append(timesDict)
                }
//                print("reservationTimesList: \(reservationTimesList)")
                ref.removeAllObservers()
                print("End getting reservatoin tim es for user")
                completionHandler(reservationTimesList)
            }
            else {
                ref.removeAllObservers()
                print("End getting reservatoin tim es for user")
                completionHandler(reservationTimesList)
            }
        })
    }
    
    // this is a partner function to getReservationTimesForUser()
    // this function checks if a Reservation object conflicts with any given times
    public func checkReservationAgainstTimesList(res: Reservation, timesList: [[String:String]]) -> Bool {
        
        // initialize whether a conflict to false
        var isConflict = false
        
        // get the start and end time of the reservation to create
        let resStartDateTime = Reservation.stringToDate(string: res.startDateTime)
        let resEndDateTime = Reservation.stringToDate(string: res.endDateTime)
        
        // loop over each "lite" reservation in the timesList from getReservationTimesForUser()
        for resLite in timesList {
            
            // get the start and end time of the spot reservation
            var liteStartDateTime = Reservation.stringToDate(string: resLite["start"]!)
            var liteEndDateTime = Reservation.stringToDate(string: resLite["end"]!)
            
            // check if the resLite is at the same Spot() as the reservation
//            print("reservation spot ID: \(res.ownerID)")
//            print("resLite spot ID: \(resLite["ownerID"] as! String)")
            if(res.spot.spot_id == resLite["spotID"] as! String) {
                print("The spot id matches")
                
                // check if there is a conflict
                if((resStartDateTime > liteStartDateTime && resStartDateTime < liteEndDateTime) || (resEndDateTime > liteStartDateTime && resEndDateTime < liteEndDateTime) || (liteStartDateTime > resStartDateTime && liteStartDateTime < resEndDateTime) || (liteEndDateTime > resStartDateTime && liteEndDateTime < resEndDateTime)) || (resStartDateTime == liteStartDateTime && resEndDateTime == liteEndDateTime){
                    print("THIS IS A CONFLICT")
                    isConflict = true
                }
                else {
                    print("This is not a conflict")
                }
            }
            else {
                print("The spot id does not match")
            }
            
        }
        return isConflict
    }
    
    // retrieve Car() object for given User() and car_ID
    public func carAtPath(carUser: String, carID: String, completionHandler: @escaping (_ car: Car) ->Void) {
        var reservationCar = Car()
        
        // database path to Car()
        let carBaseRef = Database.database().reference().child("User").child(carUser).child("Cars").child(carID)
        
        // get Car() at path
        carBaseRef.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                let carDict = ((snapshot as! DataSnapshot).value) as! NSDictionary
                print("Car Dict: \(carDict)")
                
                // car info is in carDict
                reservationCar = Car(
                    make: carDict.value(forKey: "make") as! String,
                    model: carDict.value(forKey: "model") as! String,
                    year: carDict.value(forKey: "year") as! String,
                    carImage: carDict.value(forKey: "image") as! String,
                    isDefault: carDict.value(forKey: "default") as! Bool,
                    car_id: carID)!
                completionHandler(reservationCar)
            }
            else {
                print("we could not find that car")
                
                reservationCar = Car(
                    make: "Car Info Not Found. ",
                    model: "Car has been deleted",
                    year: "",
                    carImage: "",
                    isDefault: false,
                    car_id: "")!
                
                // empty return values
                completionHandler(reservationCar)
            }
        })
    }
    
    // retrieve Spot() for given spotID
    public func spotAtPath(userID: String, spotID: String, completionHandler: @escaping (_ spot: Spot) -> Void) {
        
        // database path to Spot()
        let spotBaseRef = Database.database().reference().child("User").child(userID).child("MySpots").child(spotID)
        
        // print("Spot ID: \(spotID)")
        
        // get Spot() at path
        spotBaseRef.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                let spotDict = ((snapshot as! DataSnapshot).value) as! NSDictionary
//                print("Spot Dict: \(spotDict)")
                
                // get the image for the spot
                var spotImage = UIImage(named: "white")!
                let url = URL(string: spotDict["image"] as! String)
                if let data = try? Data(contentsOf: url!) {
                    spotImage = UIImage(data: data) ?? UIImage(named: "white")!
                }
                
                let reservationSpot = Spot(
                    address: spotDict["address"] as! String,
                    town: spotDict["city"] as! String,
                    state: spotDict["state"] as! String,
                    zipCode: spotDict["zipcode"] as! String,
                    spotImage: spotDict["image"] as! String,
                    description: spotDict["description"] as! String,
                    monStartTime: spotDict["monStartTime"] as! String,
                    monEndTime: spotDict["monEndTime"] as! String,
                    tueStartTime: spotDict["tueStartTime"] as! String,
                    tueEndTime: spotDict["tueEndTime"] as! String,
                    wedStartTime: spotDict["wedStartTime"] as! String,
                    wedEndTime: spotDict["wedEndTime"] as! String,
                    thuStartTime: spotDict["thuStartTime"] as! String,
                    thuEndTime: spotDict["thuEndTime"] as! String,
                    friStartTime: spotDict["friStartTime"] as! String,
                    friEndTime: spotDict["friEndTime"] as! String,
                    satStartTime: spotDict["satStartTime"] as! String,
                    satEndTime: spotDict["satEndTime"] as! String,
                    sunStartTime: spotDict["sunStartTime"] as! String,
                    sunEndTime: spotDict["sunEndTime"] as! String,
                    monOn: spotDict["monswitch"] as! Bool,
                    tueOn: spotDict["tueswitch"] as! Bool,
                    wedOn: spotDict["wedswitch"] as! Bool,
                    thuOn: spotDict["thuswitch"] as! Bool,
                    friOn: spotDict["friswitch"] as! Bool,
                    satOn: spotDict["satswitch"] as! Bool,
                    sunOn: spotDict["sunswitch"] as! Bool,
                    hourlyPricing: spotDict["basePricing"] as! String,
                    dailyPricing: spotDict["dailyPricing"] as! String,
                    weeklyPricing: spotDict["weeklyPricing"] as! String,
                    monthlyPricing: spotDict["monthlyPricing"] as! String,
                    weeklyOn: spotDict["switch_weekly"] as! Bool,
                    monthlyOn: spotDict["switch_monthly"] as! Bool,
                    index: 1,
                    approved: true,
                    spotImages: spotImage,
                    spots_id: spotDict["id"] as! String,
                    latitude: spotDict["user_lat"] as! String,
                    longitude: spotDict["user_long"] as! String,
                    spottype: spotDict["spot_type"] as! String,
                    owner_id: spotDict["owner_id"] as! String,
                    Email: spotDict["Email"] as! String,
                    baseprice: spotDict["basePricing"] as! String) as! Spot
                
                completionHandler(reservationSpot)
            }
            else {
                // add some error handlers here
                print("We could not find that Spot()")
                
                let reservationSpot = Spot(
                    address: "Spot Not Found",
                    town: "Spot has been deleted",
                    state: "",
                    zipCode: "",
                    spotImage: "",
                    description: "",
                    monStartTime: "",
                    monEndTime: "",
                    tueStartTime: "",
                    tueEndTime: "",
                    wedStartTime: "",
                    wedEndTime: "",
                    thuStartTime: "",
                    thuEndTime: "",
                    friStartTime: "",
                    friEndTime: "",
                    satStartTime: "",
                    satEndTime: "",
                    sunStartTime: "",
                    sunEndTime: "",
                    monOn: false,
                    tueOn: false,
                    wedOn: false,
                    thuOn: false,
                    friOn: false,
                    satOn: false,
                    sunOn: false,
                    hourlyPricing: "",
                    dailyPricing: "",
                    weeklyPricing: "",
                    monthlyPricing: "",
                    weeklyOn: false,
                    monthlyOn: false,
                    index: 1,
                    approved: true,
                    spotImages: UIImage(named: "white")!,
                    spots_id: "",
                    latitude: "",
                    longitude: "",
                    spottype: "",
                    owner_id: "",
                    Email: "",
                    baseprice: "") as! Spot
                
                completionHandler(reservationSpot)
            }
        })
    }
    
    
    public func fetch_Balance() {
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/fetch_Balance"
        
        let params: [String: Any] = ["account_id": AppState.sharedInstance.user.accounttoken]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Failed, status: \(status)")
                    print("Here is the error: \(error)")
                }
                
                if let result = response.result.value {
                    let balance = result as! NSDictionary
                    self.totalBalance = String(describing: "\(balance["Balance"]!)")
                    let intTotalBalance = Int(self.totalBalance)!%100
                    if Int(self.totalBalance) != 0 {
                        self.totalBalance = self.totalBalance.prefix(self.totalBalance.count-2) + "." + String(intTotalBalance)
                    }
                }
        }
    }
    
    public func fetch_LifeTimeBalance() {
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/fetch_LifeTimeBalance"
        
        let params: [String: Any] = ["account_id": AppState.sharedInstance.user.accounttoken]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Failed, status: \(status)")
                    print("Here is the error: \(error)")
                }
            
                if let result = response.result.value {
                    let balance = result as! NSDictionary
                    self.lifeBalance = String(describing: "\(balance["Transfer"]!)")
                    let intLifeBalance = Int(self.lifeBalance)!%100
                    if Int(self.lifeBalance) != 0 {
                        self.lifeBalance = self.lifeBalance.prefix(self.lifeBalance.count-2) + "." + String(intLifeBalance)
                    }
                }
            
        }
    }
}
