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
    @IBOutlet weak var txt_pass: UITextField!
    @IBOutlet weak var Btn_newuser: UIButton!
    
    var ProfileImagePicker = UIImagePickerController()
    var refArtists: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        txt_fname.delegate = self
        txt_lname.delegate = self
        txt_pass.delegate = self
        
        ProfileImagePicker.delegate = self
        profilePhoto.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.addGestureRecognizer(tapGestureRecognizer)
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
            let alert = UIAlertController(title: "Alert", message: "Enter First Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if txt_lname.text == ""
        {
            let alert = UIAlertController(title: "Alert", message: "Enter Last Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if txt_pass.text == ""
        {
            let alert = UIAlertController(title: "Alert", message: "Enter Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if profilePhoto.image == #imageLiteral(resourceName: "EmptyProfile")
        {
            let alert = UIAlertController(title: "Alert", message: "Select Profile Pic", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            
        let ref = Database.database().reference()
        ref.child("User").queryOrdered(byChild: "fname").queryEqual(toValue: txt_fname.text)
            .observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                
                if snapshot.exists() {
                    let alertController = UIAlertController(title: "Error", message: "mob no. already exist ", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
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
        var imageReference: StorageReference {
            return Storage.storage().reference().child("User")
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
                                   "pass":self.txt_pass.text!,
                                   "image":fullURL]
                                
                    
                    print(newuser)
                    self.refArtists.child(key!).setValue(newuser)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login_ViewController") as! Login_ViewController
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
            })
       }
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
