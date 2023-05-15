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
    @IBOutlet weak var partySizeTF: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timeSlotTestLabel.text = timeSlot
        //var
       
        // Set text field delegates
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        phoneNumberTF.delegate = self
        emailAddressTF.delegate = self
        partySizeTF.delegate = self
        
        // Add target actions for text field changes
        firstNameTF.addTarget(self, action: #selector(firstNameChanged), for: .editingChanged)
        lastNameTF.addTarget(self, action: #selector(lastNameChanged), for: .editingChanged)
        phoneNumberTF.addTarget(self, action: #selector(phoneNumberChanged), for: .editingChanged)
        emailAddressTF.addTarget(self, action: #selector(emailAddressChanged), for: .editingChanged)
        partySizeTF.addTarget(self, action: #selector(partySizeChanged), for: .editingChanged)
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
        partySize = partySizeTF.text ?? ""
    }
    func createCustomer() -> Customer {
            return Customer(name: "\(firstname) \(lastname)", phoneNumber: phoneNumber, emailAddress: emailAddress, partySize: Int(partySize) ?? 0, timeSlot: timeSlot)
        }
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        cus = createCustomer()
        navigationItem.setHidesBackButton(true, animated: false)
        //for debug
//        BookingViewController.addCustomer(customer: createCustomer())
//        if let navigationController = self.navigationController {
//            navigationController.popToRootViewController(animated: true)
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextView = segue.destination as! SeatViewController
        nextView.cus = cus
    }

    
    
}
