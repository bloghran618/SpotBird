//
//  YouViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 5/28/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import Photos


class YouViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    var ProfileImagePicker = UIImagePickerController()
    var strurl = ""
    var dict = NSDictionary()
     var hud : MBProgressHUD = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        
        
        self.hideKeyboardWhenTappedAround()
        firstName.delegate = self
        lastName.delegate = self
        ProfileImagePicker.delegate = self
        profilePhoto.isUserInteractionEnabled = true
        
        let camera = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveprofile))
        self.navigationItem.rightBarButtonItem = camera
        
       AppState.sharedInstance.user.Get_UserProfile()
    }
    
      override func viewDidAppear(_ animated: Bool) {
        if AppState.sharedInstance.user.profileImage == ""{
            self.profilePhoto.image = #imageLiteral(resourceName: "EmptyProfile")
        }
        else{
            self.profilePhoto.sd_setImage(with: URL(string: AppState.sharedInstance.user.profileImage), placeholderImage: #imageLiteral(resourceName: "Profile"))
        }
        self.firstName.text = AppState.sharedInstance.user.firstName
        self.lastName.text = AppState.sharedInstance.user.lastName
        
    }
    
   
    // udapte user profile
    @objc func saveprofile(){
        
        if firstName.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Enter First Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if lastName.text == ""
        {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Enter Last Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
        let alertController = UIAlertController(title: "Error", message: "Incorrect Password..", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        
        var imageview = UIImageView()
        var imgname = ""
        var imageReference: StorageReference {
            return Storage.storage().reference().child("User")
        }
        
        if AppState.sharedInstance.user.profileImage != "" {
            strurl = AppState.sharedInstance.user.profileImage
            imageview.sd_setImage(with: URL(string: strurl), placeholderImage: UIImage(named: "placeholder.png"))
            print(strurl)
            let startIndex = strurl.index(strurl.startIndex, offsetBy: 81)
            let endIndex = strurl.index(strurl.startIndex, offsetBy: 85)
            imgname =  String(strurl[startIndex...endIndex])
        }
        if profilePhoto.image == #imageLiteral(resourceName: "EmptyProfile"){
            let str = "User/" + AppState.sharedInstance.userid
            let ref = Database.database().reference().child(str)
            
            ref.updateChildValues([
                "fname":firstName.text,
                "lname":lastName.text!,
                "image":""
                ])
        }
            
        else if profilePhoto.image == imageview.image{
            
            guard let imageData = UIImageJPEGRepresentation(profilePhoto.image!, 0.5) else { return }
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
                            "fname":self.firstName.text,
                            "lname":self.lastName.text!,
                            "image":fullURL
                            ])
                    }
                })
            }
            
            uploadTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "NO MORE PROGRESS")
            }
            
            
        }
            
        else {
            let pictureRef = Storage.storage().reference().child("User/\(imgname)")
            pictureRef.delete { error in
                if let error = error {
                } else {
                    guard let imageData = UIImageJPEGRepresentation(self.profilePhoto.image!, 0.5) else { return }
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
                                    "fname":self.firstName.text,
                                    "lname":self.lastName.text!,
                                    "image":fullURL
                                    ])
                            }
                        })
                    }
                    uploadTask.observe(.progress) { (snapshot) in
                        print(snapshot.progress ?? "NO MORE PROGRESS")
                    }
                }
            }
            
        }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func firstNameValueChanged(_ sender: UITextField) {
        //AppState.sharedInstance.user.setFirstName(name: sender.text!)
    }
    
    @IBAction func lastNameValueChanged(_ sender: UITextField) {
        // AppState.sharedInstance.user.setLastName(name: sender.text!)
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
    
    @IBAction func ProfileImageOnClick(_ sender: Any) {
        // Close the keyboard
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        
        // Alert allows you to choose between Camera, Gallery or Cancel
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()}))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        // AppState.sharedInstance.user.profileImage = (chosenImage as! UIImage)
        // AppState.sharedInstance.user.setProfileImage(profile: chosenImage as! UIImage)
        self.profilePhoto!.image = (chosenImage as! UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        return true
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
    
    @IBAction func btn_Logout(_ sender: Any) {
        let alertController = UIAlertController(title: "Spotbirdparking", message: "Are you sur you want to logout!", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            UserDefaults.standard.removeObject(forKey: "logindata")
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
            AppState.sharedInstance.user.cars.removeAll()
            AppState.sharedInstance.spots.removeAll()
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "Login_ViewController") as! Login_ViewController
            self.present(vc, animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
