//
//  YouViewController.swift
//  Spothawk
//
//  Created by user138340 on 5/28/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import Photos
import Alamofire

class YouViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var lblTotalBalance: UILabel!
    @IBOutlet weak var lblLifeTimeBalance: UILabel!
    
       var original_pic = UIImageView()
    
    var ProfileImagePicker = UIImagePickerController()
    var strurl = ""
    var dict = NSDictionary()
     var hud : MBProgressHUD = MBProgressHUD()
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view disappearing")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappeared")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Spinner.stop()
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        self.hideKeyboardWhenTappedAround()
        firstName.delegate = self
        lastName.delegate = self
        ProfileImagePicker.delegate = self
        profilePhoto.isUserInteractionEnabled = true
        
       // AppState.sharedInstance.user.Get_UserProfile()
       
        
        if AppState.sharedInstance.user.profileImage == ""{
            self.profilePhoto.image = #imageLiteral(resourceName: "EmptyProfile")
        }
        else{
            // note that the placeholderImage is not nothing, it is UIImage.named("white"), you can change the image by double-clicking the blank
            self.profilePhoto.sd_setImage(with: URL(string: AppState.sharedInstance.user.profileImage), placeholderImage: #imageLiteral(resourceName: "white"))
            original_pic.sd_setImage(with: URL(string: AppState.sharedInstance.user.profileImage), placeholderImage: #imageLiteral(resourceName: "white"))
        }
        
        if Int(AppState.sharedInstance.user.lifeBalance) == 0 {
            print("No balance!")
            self.lblTotalBalance.text = ""
            self.lblLifeTimeBalance.text = ""
        }
        else {
            self.lblTotalBalance.attributedText = self.attributedText(withString: "Earnings Balance: $"  + AppState.sharedInstance.user.totalBalance, boldString: "Earnings Balance: ", font: UIFont.systemFont(ofSize: 17.0))
            self.lblLifeTimeBalance.attributedText = self.attributedText(withString: "Total Earnings: $"  + AppState.sharedInstance.user.lifeBalance, boldString: "Total Earnings: ", font: UIFont.systemFont(ofSize: 17.0))
        }
        
    }
    
      override func viewDidAppear(_ animated: Bool) {
        print(AppState.sharedInstance.user.firstName)
        print(AppState.sharedInstance.user.firstName)
        self.firstName.text = AppState.sharedInstance.user.firstName
        self.lastName.text = AppState.sharedInstance.user.lastName
    }
    
    // udapte user profile
    @objc func saveprofile(){
        
        print("save the profile")
        
        // close any open keyboards
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        
        if firstName.text == ""
        {
            let alert = UIAlertController(title: "Spothawk", message: "Enter First Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if lastName.text == ""
        {
            let alert = UIAlertController(title: "Spothawk", message: "Enter Last Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            print("alerts passed, start saving profile")
            
            // Save user profile
            AppState.sharedInstance.user.Set_UserProfile()
            
            // hide the save button to indicte save
            hide_save()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func firstNameValueChanged(_ sender: UITextField) {
        AppState.sharedInstance.user.firstName = sender.text!
    }
    
    @IBAction func lastNameValueChanged(_ sender: UITextField) {
        AppState.sharedInstance.user.lastName = sender.text!
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
    
    @IBAction func ProfileImageOnClick(_ sender: UITapGestureRecognizer) {
        // Close the keyboard
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        
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
        AppState.sharedInstance.user.New_img.image = (chosenImage as! UIImage)
        self.profilePhoto!.image = (chosenImage as! UIImage)
        picker.dismiss(animated: true, completion: nil)
        show_save()
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        show_save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        show_save()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
     show_save()
    }
    
    func show_save()  {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveprofile))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func hide_save() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
//        view.endEditing(true)
        print("dismiss the keyboard")
    }


}
