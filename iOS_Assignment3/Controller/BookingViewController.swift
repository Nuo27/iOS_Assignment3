//
//  ViewBookingController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import UIKit
import OHMySQL
class BookingViewController: UIViewController {
    
    //UI var
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var bookButton: UIButton!
    
    //var
    let timeSlots = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM","6:00 PM","7:00 PM","8:00 PM","9:00 PM","10:00 PM"]
    var selectedTimeSlot: String?
    static var customers: [Customer] = []
    //database config
    let user = MySQLConfiguration(user: "grouphd",password: "grouphd1",serverName: "db4free.net",dbName: "iosgroupass",port: 3306,socket: "/mysql/mysql.sock")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookButton.isEnabled = false
        bookingTableView.dataSource = self
        bookingTableView.delegate = self
        
        // Register table view cell
        bookingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TimeSlotCell")
        
        // for debug
        var customer1 = Customer(name: "John Doe", phoneNumber: "1234567890", emailAddress: "johndoe@example.com", partySize: 2, timeSlot: "10:00 AM")
        var customer2 = Customer(name: "Jane Smith", phoneNumber: "9876543210", emailAddress: "janesmith@example.com", partySize: 1, timeSlot: "3:00 PM")
        BookingViewController.customers.append(customer1)
        BookingViewController.customers.append(customer2)
        databaseCreateCustomer(customer: customer1)
        databaseCreateCustomer(customer: customer2)
        databaseDeleteCustomer(customer: customer2)
        fetchDataFromDatabase()
    }
    
    func databaseCreateCustomer(customer: Customer) {
        let name = customer.getName()
        let phoneNumber = customer.getPhoneNumber()
        let emailAddress = customer.getEmailAddress()
        let partySize = "\(customer.getPartySize())"
        let timeSlot = customer.getTimeSlot()

        // Check if the customer already exists in the local array
        if BookingViewController.customers.contains(where: { $0.getName() == name && $0.getPhoneNumber() == phoneNumber }) {
            print("Customer already exists locally.")
            return
        }
        
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        
        if coordinator.connect() {
            print("Connected successfully")
        }
        
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        let insertString = "INSERT INTO customers (name, phoneNumber, emailAddress, partySize, timeSlot) VALUES ('\(name)', '\(phoneNumber)', '\(emailAddress)', \(partySize), '\(timeSlot)');"
        let insertRequest = MySQLQueryRequest(query: insertString)
        
        do {
            try MySQLContainer.shared.mainQueryContext?.execute(insertRequest)
            
            // Add the customer to the local array after successful insertion into the database
            BookingViewController.addCustomer(customer: customer)
            
            print("Customer created and added to the database.")
        } catch {
            print("Cannot execute the query.")
        }
        
        coordinator.disconnect()
    }
    func databaseDeleteCustomer(customer: Customer) {
        let name = customer.getName()
        let phoneNumber = customer.getPhoneNumber()

        // Check if the customer exists in the local array
        guard let index = BookingViewController.customers.firstIndex(where: { $0.getName() == name && $0.getPhoneNumber() == phoneNumber }) else {
            print("Customer does not exist locally.")
            return
        }
        
        // Remove the customer from the local array
        BookingViewController.customers.remove(at: index)
        
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        
        if coordinator.connect() {
            print("Connected successfully")
        }
        
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        
        let deleteString = "DELETE FROM customer WHERE name = '\(name)' AND phoneNumber = '\(phoneNumber)';"
        let deleteRequest = MySQLQueryRequest(query: deleteString)
        
        do {
            try MySQLContainer.shared.mainQueryContext?.execute(deleteRequest)
            print("Customer deleted from the database.")
        } catch {
            print("Cannot execute the query.")
        }
        
        coordinator.disconnect()
    }

    func fetchDataFromDatabase() {
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        
        if coordinator.connect() {
            print("Connected successfully in fetching data")
        }
        
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        
        let selectString = "SELECT * FROM customer;"
        let selectRequest = MySQLQueryRequest(query: selectString)
        
        do {
            let result = try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(selectRequest) ?? []
            //print("\(result)")
            BookingViewController.customers.removeAll()
                    
                    for row in result {
                        if let name = row["name"] as? String,
                           let phoneNumber = row["phonenumber"] as? String,
                           let emailAddress = row["emailaddress"] as? String,
                           let partySize = row["partysize"] as? Int,
                           let timeSlot = row["timeslot"] as? String {
                            let customer = Customer(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, partySize: partySize, timeSlot: timeSlot)
                            
                            // Add the fetched customer to the local array
                            BookingViewController.addCustomer(customer: customer)
                        }
                    }
                    
                    print("Data fetched from the database.")
        } catch {
            print("Cannot execute the query.")
        }
        DispatchQueue.main.async {
            self.bookingTableView.reloadData()
        }
        coordinator.disconnect()
    }

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let customerDetailView = segue.destination as! CustomerDetailViewController
        if let indexPath = bookingTableView.indexPathForSelectedRow {
            selectedTimeSlot = timeSlots[indexPath.row]
        }
        customerDetailView.timeSlot = selectedTimeSlot!
    }
    
    static public func addCustomer(customer: Customer){
        self.customers.append(customer)
    }

}

    
// MARK: - UITableViewDataSource
extension BookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSlotCell", for: indexPath)
        let timeSlot = timeSlots[indexPath.row]
        
        // Find the customer for this time slot
        if let customer = BookingViewController.customers.first(where: { $0.getTimeSlot() == timeSlot }) {
            cell.textLabel?.text = "\(customer.getName()) (\(customer.getPartySize())"
        }
        else {
                cell.textLabel?.text = timeSlot // Display the time slot if no customer is assigned
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTimeSlot = timeSlots[indexPath.row]
        // Handle booking logic for the selected time slot
        print("Selected time slot: \(selectedTimeSlot)")
        
        if let selectedCustomer = BookingViewController.customers.first(where: { $0.getTimeSlot() == selectedTimeSlot }) {
                print("Selected customer: \(selectedCustomer.getName())")
                bookButton.isEnabled = false
            } else {
                bookButton.isEnabled = true
            }
    }
}

