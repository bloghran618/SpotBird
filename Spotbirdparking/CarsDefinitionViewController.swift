//
//  CarsDefinitionViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 6/3/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class CarsDefinitionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Make: UITextField!
    @IBOutlet weak var Model: UITextField!
    @IBOutlet weak var Year: UITextField!
    @IBOutlet weak var Default: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var car: Car?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Make.delegate = self
        Model.delegate = self
        Year.delegate = self
        
        print(car?.make)
        print(car?.model)
        
        // Set up the views if editing an existing Meal
        if let car = car {
            Image.image = car.carImage
            Make.text = car.make
            Model.text = car.model
            Year.text = car.year
            //TODO: Set up default behavior
        }
        
        updateSaveButtonState()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let defaultval = true
        
        car = Car(make: make, model: model, year: year, carImage: image!, isDefault: defaultval)
    }
    
    public func setCar(thisCar: Car) {
        self.car = thisCar
    }


}
