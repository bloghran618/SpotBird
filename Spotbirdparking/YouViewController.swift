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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getuserprofile()
        self.hideKeyboardWhenTappedAround()
        
        firstName.delegate = self
        lastName.delegate = self
        
        ProfileImagePicker.delegate = self
        profilePhoto.isUserInteractionEnabled = true
        
//        firstName.text = AppState.sharedInstance.user.firstName
//        lastName.text = AppState.sharedInstance.user.lastName
//        if AppState.sharedInstance.user.profileImage != UIImage.init(named: "empytProfile") {
//            profilePhoto.image = AppState.sharedInstance.user.profileImage
//        }
        
        
        let camera = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveprofile))
        self.navigationItem.rightBarButtonItem = camera
        
    }
    
    // get user data
    func getuserprofile(){
    print(AppState.sharedInstance.userid)
        
    let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
    ref.observe(.value, with:{ (snapshot: DataSnapshot) in
     if snapshot.exists()  {
    
    for snap in snapshot.children {
    self.dict = ((snap as! DataSnapshot).value) as! NSDictionary
    print(self.dict)
        
        self.firstName.text = self.dict.value(forKey: "fname") as? String
        self.lastName.text = self.dict.value(forKey: "lname") as? String
        self.strurl = (self.dict.value(forKey: "image") as? String)!
        self.profilePhoto.sd_setImage(with: URL(string: self.strurl), placeholderImage: UIImage(named: "placeholder.png"))
    
    }
    }
    })

    
  
    }
    
    // udapte user profile
    @objc func saveprofile(){
      
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("User")
        }
        print(strurl)
        let start = strurl.index(strurl.startIndex, offsetBy: 81)
        let end = strurl.index(strurl.endIndex, offsetBy: -53)
        let range = start..<end
        let imgname = strurl[range]
        print(imgname)
        
        var imageview = UIImageView()
         imageview.sd_setImage(with: URL(string: strurl), placeholderImage: UIImage(named: "placeholder.png"))
        
        if profilePhoto.image == imageview.image{
            
            guard let imageData = UIImageJPEGRepresentation(profilePhoto.image!, 0.5) else { return }
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
                        
                        
                                let str = "User/" + AppState.sharedInstance.userid
                                print(str)
                                let ref = Database.database().reference().child(str)
                        
                                ref.updateChildValues([
                                    "fname":self.firstName.text!,
                                    "lname":self.lastName.text!,
                                    "image":fullURL
                                      ])
                        
                        
                    }
                    
                })
            }
            
            uploadTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "NO MORE PROGRESS")
            }
            
          //  uploadTask.resume()
        }
        
        else {
            
            let pictureRef = Storage.storage().reference().child("User/\(imgname)")
            pictureRef.delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                      print("// Uh-oh, an error occurred!")
                } else {
                    print("File deleted successfully")
                    
                    
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
                                    "carno":self.firstName.text!,
                                    "mobno":self.lastName.text!,
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
            
            
            
            
//
     //   uploadTask.resume()
        }

     }
    
      @IBAction func btn_Logout(_ sender: Any) {
        let alertController = UIAlertController(title: "Spotbirdparking", message: "Are you sur you want to logout!", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            UserDefaults.standard.removeObject(forKey: "logindata")
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "Login_ViewController") as! Login_ViewController
            self.present(vc, animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
       }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func firstNameValueChanged(_ sender: UITextField) {
     //   AppState.sharedInstance.user.setFirstName(name: sender.text!)
    }

    @IBAction func lastNameValueChanged(_ sender: UITextField) {
      //  AppState.sharedInstance.user.setLastName(name: sender.text!)
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
//        AppState.sharedInstance.user.profileImage = (chosenImage as! UIImage)
        AppState.sharedInstance.user.setProfileImage(profile: chosenImage as! UIImage)
        self.profilePhoto!.image = AppState.sharedInstance.user.profileImage
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
