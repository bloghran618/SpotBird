//
//  CarsDefinitionViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 6/3/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Photos

class CarsDefinitionViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Make: UITextField!
    @IBOutlet weak var Model: UITextField!
    @IBOutlet weak var Year: UITextField!
    @IBOutlet weak var Default: CheckBox!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var car: Car?
    var CarImagePicker = UIImagePickerController()
    
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
            Image.image = car.carImage
            Make.text = car.make
            Model.text = car.model
            Year.text = car.year
            Default.isChecked = car.isDefault ?? false
        }
        else {
            Image.image = UIImage(named: "EmptyCar")
            Default.isChecked = true
        }
        
        updateSaveButtonState()

        // Do any additional setup after loading the view.
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
        
        var image = Image.image
        if image == nil {
            image = UIImage(named: "EmptyCar")
        }
        let make = Make.text ?? ""
        let model = Model.text ?? ""
        let year = Year.text ?? ""
        let defaultval = Default.isChecked
        
        car = Car(make: make, model: model, year: year, carImage: image!, isDefault: defaultval)
    }
    
    public func setCar(thisCar: Car) {
        self.car = thisCar
    }
    
}
