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
    // database config
    private let user = MySQLConfiguration(
        user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
        port: 3306, socket: "/mysql/mysql.sock")

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
    // show a indicator and call the databaseCreateCustomer function
    @objc func confirmButtonTapped() {
        view.isUserInteractionEnabled = false
        
        // Add a container view for the activity indicator with a border
        let containerWidth: CGFloat = 80
        let containerHeight: CGFloat = 80
        let containerView = UIView(frame: CGRect(x: (view.bounds.width - containerWidth) / 2, y: (view.bounds.height - containerHeight) / 2, width: containerWidth, height: containerHeight))
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(containerView)
        
        // Add the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: containerView.bounds.width / 2, y: containerView.bounds.height / 2)
        containerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        if let customer = createCustomer() {
            DispatchQueue.global(qos: .userInitiated).async {
                let success = self.databaseCreateCustomer(customer: customer)
                
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    
                    if success {
                        let successAlert = UIAlertController(
                            title: "Success", message: "You've placed your booking successfully", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            containerView.removeFromSuperview()
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        self.present(successAlert, animated: true)
                    } else {
                        let errorAlert = UIAlertController(
                            title: "Error", message: "Failed to book, please try again", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlert, animated: true)
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            let errorAlert = UIAlertController(
                title: "Error", message: "Failed to create customer", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(errorAlert, animated: true)
            view.isUserInteractionEnabled = true
        }
    }
    // connect to database a create a new customer records
    // get rid (Receipt ID) and store the current customer info to main page for displaying
    func databaseCreateCustomer(customer: Customer) -> Bool {
        let name = customer.getName()
        let phoneNumber = customer.getPhoneNumber()
        let emailAddress = customer.getEmailAddress()
        let partySize = "\(customer.getPartySize())"
        let timeSlot = customer.getTimeSlot()
        let date = customer.getDate()
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
            let rid = MySQLContainer.shared.mainQueryContext?.lastInsertID().intValue
            customer.setRID(rid: rid!)
            MainPageController.currentCustomer = customer
            print("Customer inserted into the database.")
            //store rid
            var existingArray = UserDefaults.standard.array(forKey: "rid") as? [Int] ?? []
            existingArray.append(rid!)
            UserDefaults.standard.set(existingArray, forKey: "rid")
            coordinator.disconnect()
            return true
        } catch {
            print("Cannot execute the query.")
            coordinator.disconnect()
            return false
        }
    }
    // do a double check just in case
    func createCustomer() -> Customer? {
        guard !firstname.isEmpty, !lastname.isEmpty, !phoneNumber.isEmpty, !emailAddress.isEmpty,
              !partySize.isEmpty, !timeSlot.isEmpty, !selectedDate.isEmpty
        else {
            return nil
        }
        return Customer(
            rid: 0, name: "\(firstname) \(lastname)", phoneNumber: phoneNumber, emailAddress: emailAddress,
            partySize: Int(partySize) ?? 0, timeSlot: timeSlot, date: selectedDate)
    }
}

