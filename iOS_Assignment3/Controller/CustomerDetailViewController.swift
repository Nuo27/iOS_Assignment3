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
    var selectedDate: String = ""
    var mostPartySize: Int = 0
    var isEditingRecord: Bool = false
    // UI var
    @IBOutlet weak var timeSlotTestLabel: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!
    @IBOutlet weak var partySizePickerView: UIPickerView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Call your function here
        navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timeSlotTestLabel.text = "Selected \(timeSlot) on \(self.selectedDate)"
        //var
        if(mostPartySize > 10){
            mostPartySize = 10
        }
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
        firstNameTF.addTarget(self, action: #selector(validateFirstNameInput), for: .editingDidEnd)
        lastNameTF.addTarget(self, action: #selector(validateLastNameInput), for: .editingDidEnd)
        phoneNumberTF.addTarget(self, action: #selector(validatePhoneInput), for: .editingDidEnd)
        emailAddressTF.addTarget(self, action: #selector(validateEmailInput), for: .editingDidEnd)
    
        
    }
    @objc func validatePhoneInput() {
        let phoneNumberWithoutSpaces = phoneNumber.replacingOccurrences(of: " ", with: "")
        let phoneNumberDigits = phoneNumberWithoutSpaces.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard phoneNumberDigits.count == 10 else {
            print("false in phone check")
            showAlert(title: "Invalid Phone Number",
                      message: "Please enter a 10-digit phone number.")
            return
        }
    }
    @objc func validateFirstNameInput() {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let letterCharacterSet = CharacterSet.letters
        
        // Check for whitespace in the firstname
        if firstname.rangeOfCharacter(from: whitespaceCharacterSet) != nil {
            showAlert(title: "Invalid First Name",
                      message: "Name must not contain space.")
            return
        }
        
        // Check if the firstname contains only letters
        if firstname.rangeOfCharacter(from: letterCharacterSet.inverted) != nil {
            showAlert(title: "Invalid First Name",
                      message: "Name must only contain letters.")
            return
        }
    }
    @objc func validateLastNameInput() {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let letterCharacterSet = CharacterSet.letters
        
        // Check for whitespace in the firstname
        if lastname.rangeOfCharacter(from: whitespaceCharacterSet) != nil {
            showAlert(title: "Invalid Last Name",
                      message: "Name must not contain space.")
            return
        }
        
        // Check if the firstname contains only letters
        if lastname.rangeOfCharacter(from: letterCharacterSet.inverted) != nil {
            showAlert(title: "Invalid Last Name",
                      message: "Name must only contain letters.")
            return
        }
    }
    @objc func validateEmailInput(){
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
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextView = segue.destination as? ConfirmViewController else {
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
        validatePhoneInput()
        validateEmailInput()
        // Assign values to the next view controller's properties
        nextView.emailAddress = emailAddress
        nextView.firstname = firstname
        nextView.lastname = lastname
        nextView.phoneNumber = phoneNumber
        nextView.partySize = partySize
        nextView.timeSlot = timeSlot
        nextView.selectedDate = selectedDate
    }
    
}
extension CustomerDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Return the number of options you want in the picker view
        return mostPartySize
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


