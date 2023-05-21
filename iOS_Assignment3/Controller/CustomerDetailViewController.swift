//
//  CustomerDetailViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import UIKit

class CustomerDetailViewController: UIViewController , UITextFieldDelegate{
    // var
    var timeSlot: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var partySize: String = ""
    var cus: Customer? = nil
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
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.text = ""
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
    func createCustomer() -> Customer? {
        guard !firstname.isEmpty, !lastname.isEmpty, !phoneNumber.isEmpty, !emailAddress.isEmpty, !partySize.isEmpty else {
                return nil
        }
        return Customer(name: "\(firstname) \(lastname)", phoneNumber: phoneNumber, emailAddress: emailAddress, partySize: Int(partySize) ?? 0, timeSlot: timeSlot)
    }
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        if let customer = createCustomer() {
                cus = customer
                navigationItem.setHidesBackButton(true, animated: false)
            } else {
                let alert = UIAlertController(title: "Error", message: "Please fill in all required fields.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
            }
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextView = segue.destination as! SeatViewController
        nextView.cus = cus
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Return the title for each row in the picker view
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        partySize = "\(row + 1)"
    }
}
