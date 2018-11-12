//
//  CarsDefinitionViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 6/3/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Photos
import Firebase


class CarsDefinitionViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Make: UITextField!
    @IBOutlet weak var Model: UITextField!
    @IBOutlet weak var Year: UITextField!
    @IBOutlet weak var Default: CheckBox!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var car: Car?
    var CarImagePicker = UIImagePickerController()
    var refArtists: DatabaseReference!
    var add = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        Make.delegate = self
        Model.delegate = self
        Year.delegate = self
        
        CarImagePicker.delegate = self
        Image.isUserInteractionEnabled = true
        
        // Set up the views if editing an existing Car
        if let car = car {
            navigationItem.title = "Edit Car"
           
            Image.sd_setImage(with: URL(string: car.carImage), placeholderImage: UIImage(named: "placeholder.png"))
            Make.text = car.make
            Model.text = car.model
            Year.text = car.year
            Default.isChecked = car.isDefault ?? false
            print(car.car_uid)
        }
        else {
            Image.image = UIImage(named: "EmptyCar")
            Default.isChecked = true
        }
        
        updateSaveButtonState()
    
        
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
    
    @IBAction func CarImageOnClick(_ sender: Any) {
        print("Choose image")
        // Close the keyboard
        Make.resignFirstResponder()
        Model.resignFirstResponder()
        Year.resignFirstResponder()
        
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
            CarImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            CarImagePicker.allowsEditing = false
            self.present(CarImagePicker, animated: true, completion: nil)
        }
            
        else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        checkGalleryPermission()
        CarImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        CarImagePicker.allowsEditing = false
        self.present(CarImagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage]
        print("Setting Image as: ")
        self.Image.image = chosenImage as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Imagepickercontroller did cancle"
        )
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Make.resignFirstResponder()
        Model.resignFirstResponder()
        Year.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        if Make.text?.isEmpty == false && Model.text?.isEmpty == false {
            saveButton.isEnabled = true
        }
        else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func checkBoxChecked(_ sender: Any) {
        Make.resignFirstResponder()
        Model.resignFirstResponder()
        Year.resignFirstResponder()
    }
    
    // MARK: - Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The CarsDefinitionViewController is not inside a navigation controller.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        guard let image = Image.image else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        print("***** Compressed Size \(imageData.description) **** ")
        
    
        
        if car?.car_uid == nil{
            // Add new car
          AppState.sharedInstance.user.SetCar(car_uid: "", make: Make.text!, Model: Model.text!, year: Year.text!, setbool: Default.isChecked, image: Image.image!,strurl:"")
            
         }
        else{
              // Update exist car
           AppState.sharedInstance.user.SetCar(car_uid: (car?.car_uid)!, make: Make.text!, Model: Model.text!, year: Year.text!, setbool: Default.isChecked, image: Image.image!, strurl: (car?.carImage)!)
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
        
    public func setCar(thisCar: Car) {
        self.car = thisCar
    }
    
}
