//
//  YouViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 5/28/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Photos

class YouViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    var ProfileImagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.delegate = self
        lastName.delegate = self
        
        ProfileImagePicker.delegate = self
        profilePhoto.isUserInteractionEnabled = true
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        print("Choose image")
        // Close the keyboard
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        
        // Alert allows you to choose between Camera, Gallery or Cancel
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()}))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        //TODO: Edit this block for UITapGestureRecognizer rather than button
        /*
         switch UIDevice.current.userInterfaceIdiom {
         case .pad:
         alert.popoverPresentationController?.sourceView = sender
         alert.popoverPresentationController?.sourceRect = sender.bounds
         alert.popoverPresentationController?.permittedArrowDirections = .up
         default:
         break
         }
         */
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
        self.profilePhoto!.image = chosenImage as? UIImage
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

}
