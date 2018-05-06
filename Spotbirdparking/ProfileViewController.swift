//
//  ProfileViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var ProfileNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var CarsLabel: UILabel!
    @IBOutlet weak var PaymentLabel: UILabel!
    @IBOutlet weak var CarsTable: UITableView!
    var ProfileImagePicker = UIImagePickerController()
    
    var cars = [Car]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileNameTextField.delegate = self
        LastNameTextField.delegate = self
        
        ProfileImagePicker.delegate = self
        ProfileImageView.isUserInteractionEnabled = true;
        
        print("CarsTable Delegate")
        CarsTable.delegate = self
        print("CarsTable Datasource")
        CarsTable.dataSource = self
        print("loadSampleCars()")
        loadSampleCars()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss if the user cancels
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Use the original representation of the image
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dict containing the original image, instead got: /(info)")
        }
        
        // Set the profile image to the selected image
        ProfileImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func SelectProfilePhoto(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard
        ProfileNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        
        //TODO: Use camera functionality
        let profileImagePickerController = UIImagePickerController()
        profileImagePickerController.sourceType = .photoLibrary
        profileImagePickerController.delegate = self
        present(profileImagePickerController, animated: true, completion: nil)
    }
    
    */
    @IBAction func ProfileImageOnClick(_ sender: UITapGestureRecognizer) {
        // Close the keyboard
        ProfileNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        
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
        ProfileImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        ProfileImagePicker.allowsEditing = false
        self.present(ProfileImagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        ProfileNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued w/ cell identifier
        let cellIdentifier = "CarTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CarCell else {
            fatalError("The dequeued cell is not an instance of carCell")
        }
        
        // Fetches the appropriate car for the data source layout.
        let car = cars[indexPath.row]
        
        // Assign values to cell elements
        cell.CarMakeModelLabel.text = car.make + ", " + car.model
        cell.CarYearLabel.text = ""
        if let y = car.year {
            cell.CarYearLabel.text = "\(y)"
        }
        cell.CarImageView.image = car.photo
        
        return cell
    }
    
    //MARK: Private Functions
    private func loadSampleCars() {
        let carPhoto1 = UIImage(named: "carPhoto1")
        
        guard let car1 = Car(make: "Toyota", model: "Rav4", photo: carPhoto1, year: 1999, defaultSetting: true) else {
            fatalError("Unable to instantiate Default Car")
        }
        
        cars += [car1]
        print(cars)
    }

}

