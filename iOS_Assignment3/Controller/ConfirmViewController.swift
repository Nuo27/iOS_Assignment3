//
//  ConfirmViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import OHMySQL
import UIKit

class ConfirmViewController: UIViewController {
    // var
    var selectedDate: String = ""
    var timeSlot: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var partySize: String = ""

    // ui
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeSlotLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var partySizeLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Add target action to the confirm button
        confirmBtn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        // display
        dateLabel.text = "Date: \(selectedDate)"
        timeSlotLabel.text = "Time Slot: \(timeSlot)"
        nameLabel.text = "Name: \(firstname) \(lastname)"
        phoneNumberLabel.text = "Phone Number: \(phoneNumber)"
        emailLabel.text = "Email: \(emailAddress)"
        partySizeLabel.text = "Party Size: \(partySize)"
    }
    
    @objc func confirmButtonTapped() {
        view.isUserInteractionEnabled = false
        if let customer = createCustomer() {
            if databaseCreateCustomer(customer: customer) {
                navigationController?.popToRootViewController(animated: true)
            } else {
                let alert = UIAlertController(
                    title: "Error", message: "Failed to create customer", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
                view.isUserInteractionEnabled = true
            }
        } else {
            let alert = UIAlertController(
                title: "Error", message: "Failed to create customer", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            view.isUserInteractionEnabled = true
        }
    }
    func databaseCreateCustomer(customer: Customer) -> Bool {
        let name = customer.getName()
        let phoneNumber = customer.getPhoneNumber()
        let emailAddress = customer.getEmailAddress()
        let partySize = "\(customer.getPartySize())"
        let timeSlot = customer.getTimeSlot()
        let date = customer.getDate()
        let user = MySQLConfiguration(
            user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
            port: 3306, socket: "/mysql/mysql.sock")
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        if coordinator.connect() {
            print("Connected successfully")
        }
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        let insertString =
        "INSERT INTO customer (name, phoneNumber, emailAddress, partySize, timeSlot, date) VALUES ('\(name)', '\(phoneNumber)', '\(emailAddress)', \(partySize), '\(timeSlot)', '\(date)');"
        let insertRequest = MySQLQueryRequest(query: insertString)
        do {
            try MySQLContainer.shared.mainQueryContext?.execute(insertRequest)
            BookingViewController.addCustomer(customer: customer)
            MainPageController.currentCustomer = customer
            print("Customer inserted into the database.")
            coordinator.disconnect()
            return true
        } catch {
            print("Cannot execute the query.")
            coordinator.disconnect()
            return false
        }
    }
    func createCustomer() -> Customer? {
        guard !firstname.isEmpty, !lastname.isEmpty, !phoneNumber.isEmpty, !emailAddress.isEmpty,
              !partySize.isEmpty
        else {
            return nil
        }
        return Customer(
            name: "\(firstname) \(lastname)", phoneNumber: phoneNumber, emailAddress: emailAddress,
            partySize: Int(partySize) ?? 0, timeSlot: timeSlot, date: selectedDate)
    }
}

