//
//  ConfirmViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//


import Foundation
import UIKit
class ConfirmViewController: UIViewController {
    var timeSlot: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var partySize: String = ""
    @IBOutlet weak var confirmBtn: UIButton!
    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
            // Add target action to the confirm button
            confirmBtn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        }
        
    @objc func confirmButtonTapped() {
        let bookingViewController = BookingViewController()
        if let customer = createCustomer() {
            bookingViewController.databaseCreateCustomer(customer: customer)
                navigationController?.popToRootViewController(animated: true)
            } else {
                // print out all var
                print(timeSlot)
                print(firstname)
                print(lastname)
                print(phoneNumber)
                print(emailAddress)
                print(partySize)
                // show alert
                let alert = UIAlertController(title: "Error", message: "Please fill in all the fields", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
            }
    }
    func createCustomer() -> Customer? {
        guard !firstname.isEmpty, !lastname.isEmpty, !phoneNumber.isEmpty, !emailAddress.isEmpty, !partySize.isEmpty else {
                return nil
        }
        return Customer(name: "\(firstname) \(lastname)", phoneNumber: phoneNumber, emailAddress: emailAddress, partySize: Int(partySize) ?? 0, timeSlot: timeSlot)
    }


}
