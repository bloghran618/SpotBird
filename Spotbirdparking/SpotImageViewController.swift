//
//  SpotImageViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 7/16/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Photos

class SpotImageViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var schedulingBarButton: UIBarButtonItem!
    @IBOutlet weak var spotDescription: UITextView!
    
    let defaultImage = "addButton"
    var spotImagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       spotImagePicker.delegate = self
        spotImageView.isUserInteractionEnabled = true
        
        if AppState.sharedInstance.activeSpot.spot_id == "" {
            spotImageView.image = AppState.sharedInstance.activeSpot.spotImage1
         }
        else {
          if AppState.sharedInstance.activeSpot.spotImage.count != nil{
                spotImageView.sd_setImage(with: URL(string: AppState.sharedInstance.activeSpot.spotImage), placeholderImage: UIImage(named: "placeholder.png"))
            }else {
                spotImageView.image = #imageLiteral(resourceName: "emptySpot")
            AppState.sharedInstance.activeSpot.spotImage1 =  spotImageView.image!
            }
        }

        
        spotDescription.text = AppState.sharedInstance.activeSpot.description
        schedulingBarButton.isEnabled = schedulingBarButtonCheckEnable()
        
        self.spotDescription.delegate = self
        if(AppState.sharedInstance.activeSpot.description == "") {
            spotDescription.text = "Enter Spot Desccription Here"
            spotDescription.textColor = UIColor.lightGray
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SpotImageViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SpotImageViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func SpotImageOnClick(_ sender: Any) {
        print("Choose image")
        self.spotDescription.resignFirstResponder()
        
        // Alert allows you to choose between Camera, Gallery or Cancel
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()}))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            spotImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            spotImagePicker.allowsEditing = false
            self.present(spotImagePicker, animated: true, completion: nil)
            AppState.sharedInstance.activeSpot.spotImage1 = spotImageView.image!
        }
        else
        {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        checkGalleryPermission()
        spotImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        spotImagePicker.allowsEditing = false
        self.present(spotImagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage]
        AppState.sharedInstance.activeSpot.spotImage1 = (chosenImage as? UIImage)!
        self.spotImageView!.image = chosenImage as! UIImage
        
        schedulingBarButtonCheckEnable()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if spotDescription.textColor == UIColor.lightGray {
            spotDescription.text = nil
            spotDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if spotDescription.text.isEmpty {
            spotDescription.text = "Enter Spot Desccription Here"
            spotDescription.textColor = UIColor.lightGray
        }
        spotDescription.resignFirstResponder()
        AppState.sharedInstance.activeSpot.description = spotDescription.text
        schedulingBarButtonCheckEnable()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if spotDescription.text.isEmpty {
            spotDescription.text = "Enter Spot Description Here"
            spotDescription.textColor = UIColor.lightGray
        }
        spotDescription.resignFirstResponder()
        AppState.sharedInstance.activeSpot.description = spotDescription.text
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = 0
        }
    }
    
    func schedulingBarButtonCheckEnable() -> Bool {
       
        if(AppState.sharedInstance.activeSpot.spotImage1 != UIImage.init(named: "addButton") && AppState.sharedInstance.activeSpot.description != "") {
            self.schedulingBarButton.isEnabled = true
            return true
        }
        else {
            self.schedulingBarButton.isEnabled = false
            return false
        }
    }
}
