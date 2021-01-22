//
//  SpotImageViewController.swift
//  LightPark
//
//  Created by Brian Loughran on 7/16/18.
//  Copyright © 2020 LightPark. All rights reserved.
//

import UIKit
import Photos

class SpotImageViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var schedulingBarButton: UIBarButtonItem!
    @IBOutlet weak var spotDescription: UITextView!
    
    let defaultImage = "addButton"
    var spotImagePicker = UIImagePickerController()
    let descriptionText = "Clearly explain how someone will access your parking spot. This description be available only after the user pays for your parking spot. "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        spotDescription.layer.borderWidth = 1.0
//        spotDescription.layer.borderColor = UIColor.lightGray.cgColor
//        spotDescription.layer.cornerRadius = 8
        
        print(AppState.sharedInstance.activeSpot.address)
        print(AppState.sharedInstance.activeSpot.state)
        
        spotImagePicker.delegate = self
        spotImageView.isUserInteractionEnabled = true
        
        // check if the spot exists in the database
        if AppState.sharedInstance.activeSpot.spot_id == "" {
            // if not in database, use image from activeSpot
            spotImageView.image = AppState.sharedInstance.activeSpot.spotImage1
         }
        else {
            if AppState.sharedInstance.activeSpot.spotImage.count != nil {
                // get the image from the database
                spotImageView.sd_setImage(with: URL(string: AppState.sharedInstance.activeSpot.spotImage), placeholderImage: UIImage(named: "Placeholder"))
                AppState.sharedInstance.activeSpot.spotImage1 = spotImageView.image!
            }else {
                // set to a default image
                spotImageView.image = #imageLiteral(resourceName: "emptySpot")
            AppState.sharedInstance.activeSpot.spotImage1 =  spotImageView.image!
            }
        }

        
        spotDescription.text = AppState.sharedInstance.activeSpot.description
        schedulingBarButton.isEnabled = schedulingBarButtonCheckEnable()
        
        self.spotDescription.delegate = self
        if(AppState.sharedInstance.activeSpot.description == "") {
            spotDescription.text = self.descriptionText
            spotDescription.textColor = UIColor.lightGray
            spotDescription.textAlignment = .center
        }
        else {
            spotDescription.textAlignment = .left
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      spotDescription.autocorrectionType = .no
    spotDescription.resignFirstResponder()
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
        case .limited:
            print("User has limited permissions")
        }
    }
    
    @IBAction func SpotImageOnClick(_ sender: UITapGestureRecognizer) {
        print("Choose image")
        self.spotDescription.resignFirstResponder()
        
        // Alert allows you to choose between Camera, Gallery or Cancel
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()}))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        
        // present as popoverPresentationController if iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender.view as! UIView
            alert.popoverPresentationController?.sourceRect = (sender.view as! UIView).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
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
        spotDescription.textAlignment = .left
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if spotDescription.text.isEmpty {
            spotDescription.text = self.descriptionText
            spotDescription.textColor = UIColor.lightGray
            spotDescription.textAlignment = .center
        }
        spotDescription.resignFirstResponder()
        AppState.sharedInstance.activeSpot.description = spotDescription.text
        schedulingBarButtonCheckEnable()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if spotDescription.text.isEmpty {
            spotDescription.text = self.descriptionText
            spotDescription.textColor = UIColor.lightGray
            spotDescription.textAlignment = .center
        }
        spotDescription.resignFirstResponder()
        AppState.sharedInstance.activeSpot.description = spotDescription.text
        return true
    }
    
    // If the user presses enter the textview should return
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            self.view.frame.origin.y -= keyboardSize.height
//        }
//    }
    
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            self.view.frame.origin.y = 0
//        }
//    }
    
    // Check if the user has completed the workflow and can move forward
    func schedulingBarButtonCheckEnable() -> Bool {
       
        if(AppState.sharedInstance.activeSpot.spotImage1 != UIImage.init(named: "emptySpot") && AppState.sharedInstance.activeSpot.description != "") {
            self.schedulingBarButton.isEnabled = true
            return true
        }
        else {
            self.schedulingBarButton.isEnabled = false
            return false
        }
    }
}
