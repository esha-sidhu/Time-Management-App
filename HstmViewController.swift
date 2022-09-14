//
//  HstmViewController.swift
//  HSTM
//
//  Created by Esha Sidhu
//

import UIKit
import os.log

class HstmViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    //@IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var typeEvent: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descEvent: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
         This value is either passed by `HstmTableViewController` in `prepare(for:sender:)`
         or constructed as part of adding a new event.
     */
    var hstm: HSTM?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing event.
        if let hstm = hstm {
            navigationItem.title = hstm.name
            nameTextField.text = hstm.name
            //photoImageView.image = UIImage(named: "homework")
            ratingControl.rating = hstm.rating
            typeEvent.text = hstm.eventtype
            datePicker.date = hstm.eventdate!
            descEvent.text = hstm.eventdescription
        }
        
        // Enable the Save button only if the text field has a valid event name.
        updateSaveButtonState()
    }
    
    //UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        //photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddHstmMode = presentingViewController is UINavigationController
        
        if isPresentingInAddHstmMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The HstmViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        var photo = UIImage(named: "homework")
        //photoImageView.image
        let rating = ratingControl.rating
        let eventtype = typeEvent.text
        let eventdescription = descEvent.text
        let eventdate = datePicker.date
        
        print("Adding object ", name," : ", eventtype, " : ", eventdescription)
        
        if( eventtype == "Quiz") {
            photo = UIImage(named: "quiz")
        } else if (eventtype == "Xtra") {
            photo = UIImage(named: "xtra")
        }
        
        // Set the event to be passed to HstmTableViewController after the unwind segue.
        hstm = HSTM(name: name, photo: photo, rating: rating, eventtype: eventtype ?? "Homework", eventdescription: eventdescription ?? "Sample desc", eventdate: eventdate)
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
}

