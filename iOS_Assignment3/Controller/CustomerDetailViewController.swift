//
//  CustomerDetailViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import UIKit

class CustomerDetailViewController: UIViewController, UITextFieldDelegate {
    // var
    var timeSlot: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var partySize: String = "1"
    // UI var
    @IBOutlet weak var timeSlotTestLabel: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!
    @IBOutlet weak var partySizePickerView: UIPickerView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timeSlotTestLabel.text = "Selected timeSlot is : \(timeSlot)"
        //var
        
        // Set text field delegates
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        phoneNumberTF.delegate = self
        emailAddressTF.delegate = self
        //picker delegates
        partySizePickerView.delegate = self
        partySizePickerView.dataSource = self
        
        // Add target actions for text field changes
        firstNameTF.addTarget(self, action: #selector(firstNameChanged), for: .editingChanged)
        lastNameTF.addTarget(self, action: #selector(lastNameChanged), for: .editingChanged)
        phoneNumberTF.addTarget(self, action: #selector(phoneNumberChanged), for: .editingChanged)
        emailAddressTF.addTarget(self, action: #selector(emailAddressChanged), for: .editingChanged)
        // vaild check
        phoneNumberTF.addTarget(self, action: #selector(validateInputs), for: .editingDidEnd)
        emailAddressTF.addTarget(self, action: #selector(validateInputs), for: .editingDidEnd)
    
        
    }
    @objc func validateInputs() {
        let phoneNumberWithoutSpaces = phoneNumber.replacingOccurrences(of: " ", with: "")
        let phoneNumberDigits = phoneNumberWithoutSpaces.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard phoneNumberDigits.count == 10 else {
            print("false in phone check")
            showAlert(title: "Invalid Phone Number",
                      message: "Please enter a 10-digit phone number.")
            return
        }

        // Validate email address format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: emailAddress) else {
            print("false in email check")
            showAlert(title: "Invalid Email address",
                      message: "Please enter a valid email address.")
            return
        }
    }


    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title, message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //textField.text = ""
    }
    // Handle text field changes
    @objc func firstNameChanged() {
        firstname = firstNameTF.text ?? ""
    }
    
    @objc func lastNameChanged() {
        lastname = lastNameTF.text ?? ""
    }
    
    @objc func phoneNumberChanged() {
        phoneNumber = phoneNumberTF.text ?? ""
    }
    
    @objc func emailAddressChanged() {
        emailAddress = emailAddressTF.text ?? ""
    }
    
    @objc func partySizeChanged() {
        let selectedRow = partySizePickerView.selectedRow(inComponent: 0)
        partySize = "\(selectedRow + 1)"
    }
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        // test case removed
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextView = segue.destination as? SeatViewController else {
            return
        }
        
        if firstname.isEmpty || lastname.isEmpty || phoneNumber.isEmpty || emailAddress.isEmpty
            || partySize.isEmpty
        {
            let alertController = UIAlertController(
                title: "Missing Information", message: "Please fill in all required fields.",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        validateInputs()
        // Assign values to the next view controller's properties
        nextView.emailAddress = emailAddress
        nextView.firstname = firstname
        nextView.lastname = lastname
        nextView.phoneNumber = phoneNumber
        nextView.partySize = partySize
        nextView.timeSlot = timeSlot
    }
    
}
extension CustomerDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Return the number of options you want in the picker view
        return 15
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
    -> String?
    {
        // Return the title for each row in the picker view
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        partySize = "\(row + 1)"
    }
}


