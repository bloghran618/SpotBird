//
//  ProvideIDDocViewController.swift
//  Spothawk
//
//  Created by user138340 on 5/25/19.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit
import Photos
import Firebase
import Alamofire


class ProvideIDDocViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var frontIDLabel: UILabel!
    @IBOutlet weak var backIDLabel: UILabel!
    @IBOutlet weak var frontIDImage: UIImageView!
    @IBOutlet weak var backIDImage: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var frontOrBackImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
    }

    // check if the user has authorized access to photos
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
    
    // run when you tap the front ID image
    @IBAction func frontIDTapGesture(_ sender: Any) {
        // indicate the front image was tapped
        print("The front image was tapped")
        frontOrBackImage = "front"
        
        // Alert allows you to choose between Camera, Gallery or Cancel
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()}))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // run when you tap the back ID image
    @IBAction func backIDTapGesture(_ sender: Any) {
        // indicate the back image was tapped
        print("The back image was tapped")
        frontOrBackImage = "back"
        
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
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
            
        else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        checkGalleryPermission()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // set the appropriate UIImage with the chosen image
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage]
        AppState.sharedInstance.user.New_img.image = (chosenImage as! UIImage)
        
        if frontOrBackImage == "front" {
            // set the front image
            self.frontIDImage!.image = (chosenImage as! UIImage)
            
            // update the front label
            if frontIDImage.image != UIImage(named: "emptySpot") {
                frontIDLabel.text = "ID Front"
                frontIDLabel.textColor = UIColor.black
            }
        }
        else {
            // set the back image
            self.backIDImage!.image = (chosenImage as! UIImage)
            
            // update the back label
            if backIDImage.image != UIImage(named: "emptySpot") {
                backIDLabel.text = "ID Back"
                backIDLabel.textColor = UIColor.black
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // user hit cancel on the imagePicker
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func whyStripeIDButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://support.stripe.com/questions/passport-id-or-drivers-license-upload-requirement")! as URL, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func submitInfoButton(_ sender: Any) {
        
        // check the images are not empty
        if frontIDImage.image == UIImage(named: "emptySpot") {
            frontIDLabel.text = "Empty ID Front"
            frontIDLabel.textColor = UIColor.red
        }
        if backIDImage.image == UIImage(named: "emptySpot") {
            backIDLabel.text = "Empty ID Back"
            backIDLabel.textColor = UIColor.red
        }
        
        // exit function if either image is empty
        if frontIDImage.image == UIImage(named: "emptySpot") || backIDImage.image == UIImage(named: "emptySpot") {
            return
        }
        
        // send the pictures to firebase
        uploadPicsToStripe(frontImage: frontIDImage.image!, backImage: backIDImage.image!)
        
    }
    
    //    This function will be moved to the idDocumentViewController()
    func uploadPicsToStripe(frontImage: UIImage, backImage: UIImage) {
        print("thats some progress")
        
        // convert pictures to correct data type
        let frontData = UIImageJPEGRepresentation(frontImage, 0.5)
        let backData = UIImageJPEGRepresentation(backImage, 0.5)
        
        // make reference to where you are storing the pictures
        var storageRef: StorageReference {
            return Storage.storage().reference().child("temp")
        }
        let randomUser = User()
        let frontRandomString = randomUser.randomStringWithLength(length: 8) as! String
        let backRandomString = randomUser.randomStringWithLength(length: 8) as! String
        let frontImageRef = storageRef.child(frontRandomString + ".jpg")
        let backImageRef = storageRef.child(backRandomString + ".jpg")
        
        // upload the front picture
        let frontUploadTask = frontImageRef.putData(frontData!)
        
        // watch the upload for status (can also do .progress, .pause, .resume)
        frontUploadTask.observe(.success) { snapshot in
            print("Front upload was a success")
            
            // upload the back picture
            let backUploadTask = backImageRef.putData(backData!)
            
            backUploadTask.observe(.success) { snapshot in
                print("Back upload was a success")
                
                // send an alamofire request to submit docs to backend
                self.submitIDsToStripe(frontIDPath: frontRandomString + ".jpg", backIDPath: backRandomString + ".jpg")
                
            }
            
            // handle back picture cannot upload
            backUploadTask.observe(.failure) { snapshot in
                // if front is a success and back is a failure make sure to clean front from storage
                self.deletePicFromFirebase(pic_id: frontRandomString)
                print("Back upload was a failure")
            }
        }
        
        // handle front picture cannot upload
        frontUploadTask.observe(.failure) { snapshot in
            print("Front upload was a failure")
        }
        
        print("done...")
    }
    
    func deletePicFromFirebase(pic_id: String) {
        
        // make reference to the picture to delete
        var storageRef: StorageReference {
            return Storage.storage().reference().child("temp")
        }
        let imageRef = storageRef.child(pic_id + ".jpg")
        
        // delete the picture
        imageRef.delete { error in
            if let error = error {
                print("ERROR: the picture was not deleted")
                print("MESSAGE: \(error)")
            }
            else {
                print("The picture (ID=\(pic_id)) was successfully deleted")
            }
        }
    }
    
    func submitIDsToStripe(frontIDPath: String, backIDPath: String) {
        
        // Configure alamofire request to submit docs to stripe
        var url = "https://spotbird-backend-bloughran618.herokuapp.com/upload_id_docs"
        var params: [String: Any] = [
            "account_id": AppState.sharedInstance.user.accounttoken,
            "front_image_id": frontIDPath,
            "back_image_id": backIDPath
        ]
        
        // Send the docs to Stripe (will not work if already submitted)
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                    self.navigationController?.popViewController(animated: true)
                    
                    // delete the pictures as cleanup
                    self.deletePicFromFirebase(pic_id: frontIDPath)
                    self.deletePicFromFirebase(pic_id: backIDPath)
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Failed, status: \(status)")
                    print("Here is the error: \(error)")
                    
                    // delete the pictures as cleanup
                    self.deletePicFromFirebase(pic_id: frontIDPath)
                    self.deletePicFromFirebase(pic_id: backIDPath)
                }
            }
    }
    
}
