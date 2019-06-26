//
//  Signup_ViewController.swift
//  Spotbirdparking
//
//  Created by mac on 01/10/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//


import UIKit
import Firebase
import Photos

class Signup_ViewController: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var txt_fname: UITextField!
    @IBOutlet weak var txt_lname: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var txt_pass: UITextField!
    @IBOutlet weak var Btn_newuser: UIButton!
    
    var ProfileImagePicker = UIImagePickerController()
    var refArtists: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhoto.layer.borderWidth = 0
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        
        txt_fname.delegate = self
        txt_lname.delegate = self
        txt_pass.delegate = self
        
        ProfileImagePicker.delegate = self
        profilePhoto.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.addGestureRecognizer(tapGestureRecognizer)
        
        txt_fname.autocorrectionType  = .no
        txt_lname.autocorrectionType = .no
        txt_username.autocorrectionType = .no
        txt_pass.autocorrectionType = .no
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Close the keyboard
        txt_fname.resignFirstResponder()
        txt_lname.resignFirstResponder()
        txt_pass.resignFirstResponder()
        
        // Alert allows you to choose between Camera, Gallery or Cancel
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()}))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btn_login(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login_ViewController") as! Login_ViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btn_register(_ sender: Any) {
        
        if txt_fname.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Enter First Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if txt_lname.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Enter Last Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if txt_email.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Enter Email", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if txt_username.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Enter User Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if txt_pass.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (txt_pass.text?.count)! < 8
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Minimum 8 character Password ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            

            Spinner.start()
            let ref = Database.database().reference()
            ref.child("User").queryOrdered(byChild: "uname").queryEqual(toValue: txt_username.text)
                .observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                    
                    if snapshot.exists() {
                        Spinner.stop()
                        self.view.endEditing(true)
                        let alertController = UIAlertController(title: "Spotbirdparking", message: "User Name already exist ", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        self.view.endEditing(true)
                        Spinner.start()
                        self.save_newuser()
                        
                    }
                    
                })
        }
        
    }
    
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            //TODO: Test functionality with a real camera
            ProfileImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            ProfileImagePicker.allowsEditing = false
            self.present(ProfileImagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        checkGalleryPermission()
        ProfileImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        ProfileImagePicker.allowsEditing = false
        self.present(ProfileImagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage]
        self.profilePhoto.image = chosenImage as? UIImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkGalleryPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func save_newuser()
    {
        let customerToken = MyAPIClient.sharedClient.createCustomerID()
        print("asdf, yes we are creating an account token")
        let accountToken = MyAPIClient.sharedClient.createAccountID()
        print("qwer")
        
        
        if (profilePhoto.image?.isEqual(UIImage(named: "logo")))!
        {
            self.refArtists = Database.database().reference().child("User");
            let key = self.refArtists.childByAutoId().key
            let newuser = ["id":key,
                           "fname":self.txt_fname.text!,
                           "lname":self.txt_lname.text!,
                           "uname":self.txt_username.text!,
                           "pass":self.txt_pass.text!,
                           "image":"",
                           "email":txt_email.text!,
                           "customerToken": customerToken,
                           "accountToken": accountToken]
            print(newuser)
            
            self.refArtists.child(key!).setValue(newuser){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                    Spinner.stop()
                    
                } else {
                    Spinner.stop()
                    self.getlogin(id: key!)
                    print("Data saved successfully!")
                    
                }
            }
            
        }
        else {
            
            var imageReference: StorageReference {
                return Storage.storage().reference().child("User/")
            }
            guard let imageData = UIImageJPEGRepresentation(profilePhoto.image!, 0.5) else { return }
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
                        self.refArtists = Database.database().reference().child("User");
                        let key = self.refArtists.childByAutoId().key
                        let newuser = ["id":key,
                                       "fname":self.txt_fname.text!,
                                       "lname":self.txt_lname.text!,
                                       "uname":self.txt_username.text!,
                                       "pass":self.txt_pass.text!,
                                       "image":fullURL,
                                       "customerToken": customerToken,
                                       "accountToken": accountToken]
                        print(newuser)
                        self.refArtists.child(key!).setValue(newuser){
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                print("Data could not be saved: \(error).")
                                Spinner.stop()
                                
                            } else {
                                Spinner.stop()
                                self.getlogin(id: key!)
                                print("Data saved successfully!")
                                
                            }
                        }
                        
                        
                    }
                })
            }
            
        }
    }
    
    func getlogin(id:String){
        
        self.refArtists = Database.database().reference().child("User").child(id);
        
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    print(snapshotValue)
                    AppState.sharedInstance.userid = snapshotValue.value(forKey: "id") as! String
                    
//                    UserDefaults.standard.setValue(snapshotValue, forKey: "logindata")
//                    UserDefaults.standard.synchronize()
                    
                    
                    var logindata =  NSMutableDictionary()
                    
                    logindata.setValue(snapshotValue.value(forKey: "fname") as!String, forKey: "fname")
                    logindata.setValue(snapshotValue.value(forKey: "id") as!String, forKey: "id")
                    logindata.setValue(snapshotValue.value(forKey: "email") as!String, forKey: "email")
                    logindata.setValue(snapshotValue.value(forKey: "lname") as!String, forKey: "lname")
                    
                    if snapshotValue.value(forKey: "image") != nil{
                        logindata.setValue(snapshotValue.value(forKey: "image") as!String, forKey: "CustomerToken")
                    }
                    if snapshotValue.value(forKey: "CustomerToken") != nil{
                        logindata.setValue(snapshotValue.value(forKey: "CustomerToken") as!String, forKey: "CustomerToken")
                    }
                    if snapshotValue.value(forKey: "accountToken") != nil{
                        logindata.setValue(snapshotValue.value(forKey: "accountToken") as!String, forKey: "accountToken")
                    }
                    
                    UserDefaults.standard.setValue(logindata, forKey: "logindata")
                    UserDefaults.standard.synchronize()
                    
                   let data_login = UserDefaults.standard.value(forKey: "logindata") as! NSDictionary
                    
                    AppState.sharedInstance.user.customertoken = data_login.value(forKey: "customerToken") as? String ?? ""
                    AppState.sharedInstance.user.accounttoken = data_login.value(forKey: "accountToken") as? String ?? ""
                    AppState.sharedInstance.user.firstName = (data_login.value(forKey: "fname") as? String)!
                    AppState.sharedInstance.user.lastName = (data_login.value(forKey: "lname") as? String)!
                    AppState.sharedInstance.user.profileImage = (snapshotValue.value(forKey: "image") as? String)!
                    
                    print("Last name 2: \(AppState.sharedInstance.user.lastName)")
                    print("Customer Token 2: \(AppState.sharedInstance.user.customertoken)")
                    
                    if AppState.sharedInstance.user.profileImage != "" {
                        let strurl = AppState.sharedInstance.user.profileImage
                        let startIndex = strurl.index(strurl.startIndex, offsetBy: 81)
                        let endIndex = strurl.index(strurl.startIndex, offsetBy: 85)
                        AppState.sharedInstance.user.imgname =  String(strurl[startIndex...endIndex])
                    }
                    
                    
                    Spinner.stop()
                    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                    let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "myTabbarControllerID")
                    appDelegate.window?.rootViewController = initialViewController
                    appDelegate.window?.makeKeyAndVisible()
                    
                }
            }
        })
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
}
