//
//  Database.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 23/5/2023.
//

import Foundation
import OHMySQL

class Database{
    let user = MySQLConfiguration(
        user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
        port: 3306, socket: "/mysql/mysql.sock")
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
            BookingViewController.addCustomer(customer: customer)
            MainPageController.currentCustomer = customer
            print("Customer inserted into the database.")
            
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
    func databaseDeleteCustomer(customer: Customer) -> Bool {
        let name = customer.getName()
        let phoneNumber = customer.getPhoneNumber()
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        if coordinator.connect() {
            print("Connected successfully")
        }
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        let deleteString =
        "DELETE FROM customer WHERE name = '\(name)' AND phoneNumber = '\(phoneNumber)';"
        let deleteRequest = MySQLQueryRequest(query: deleteString)
        do {
            try MySQLContainer.shared.mainQueryContext?.execute(deleteRequest)
            print("Customer deleted from the database.")
            coordinator.disconnect()
            return true
        } catch {
            print("Cannot execute the query.")
            coordinator.disconnect()
            return false
        }
    }
    func guestFetchDataFromDatabase(RIDs: [Int]) {
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        if coordinator.connect() {
            print("Connected successfully in fetching data")
        }
        
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        let ridsString = RIDs.map { String($0) }.joined(separator: ",")
        let selectString = "SELECT * FROM customer WHERE RID IN (\(ridsString));"
        let selectRequest = MySQLQueryRequest(query: selectString)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak activityIndicator] in
            guard let self = self else { return }
            
            do {
                let result = try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(selectRequest) ?? []
                BookingViewController.customers.removeAll()
                
                for row in result {
                    if let rid = row["RID"] as? Int,
                       let name = row["name"] as? String,
                       let phoneNumber = row["phonenumber"] as? String,
                       let emailAddress = row["emailaddress"] as? String,
                       let partySize = row["partysize"] as? Int,
                       let timeSlot = row["timeslot"] as? String,
                       let date = row["date"] as? String
                    {
                        let customer = Customer(rid: rid, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, partySize: partySize, timeSlot: timeSlot, date: date)
                        print(rid)
                        // Add the fetched customer to the local array
                        BookingViewController.addCustomer(customer: customer)
                    }
                }
                
                print("Data fetched from the database.")
                
                DispatchQueue.main.async {
                    // Hide loading indicator
                    activityIndicator?.stopAnimating()
                    activityIndicator?.removeFromSuperview()
                    
                    self.bookingTableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    // Hide loading indicator
                    activityIndicator?.stopAnimating()
                    activityIndicator?.removeFromSuperview()
                    
                    print("Cannot execute the query.")
                }
            }
            
            coordinator.disconnect()
        }
    }
    func adminFetchDataFromDatabase(viewingDate: String, selectedTimeSlot: String) {
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        print(viewingDate)
        print(selectedTimeSlot)
        if coordinator.connect() {
            print("Connected successfully in fetching data")
        }
        
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        
        let selectString = "SELECT * FROM customer WHERE date = '\(viewingDate)' AND timeslot = '\(selectedTimeSlot)';"
        let selectRequest = MySQLQueryRequest(query: selectString)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak activityIndicator] in
            guard let self = self else { return }
            
            do {
                let result = try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(selectRequest) ?? []
                BookingViewController.customers.removeAll()
                
                for row in result {
                    if let rid = row["RID"] as? Int,
                       let name = row["name"] as? String,
                       let phoneNumber = row["phonenumber"] as? String,
                       let emailAddress = row["emailaddress"] as? String,
                       let partySize = row["partysize"] as? Int,
                       let timeSlot = row["timeslot"] as? String,
                       let date = row["date"] as? String
                    {
                        let customer = Customer(rid: rid, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, partySize: partySize, timeSlot: timeSlot, date: date)
                        print(rid)
                        // Add the fetched customer to the local array
                        BookingViewController.addCustomer(customer: customer)
                    }
                }
                
                print("Data fetched from the database.")
                
                DispatchQueue.main.async {
                    // Hide loading indicator
                    activityIndicator?.stopAnimating()
                    activityIndicator?.removeFromSuperview()
                    
                    self.bookingTableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    // Hide loading indicator
                    activityIndicator?.stopAnimating()
                    activityIndicator?.removeFromSuperview()
                    
                    print("Cannot execute the query.")
                }
            }
            
            coordinator.disconnect()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let customerDetailView = segue.destination as! CustomerDetailViewController
        if let indexPath = bookingTableView.indexPathForSelectedRow {
            selectedTimeSlot = timeSlots[indexPath.row]
        }
        customerDetailView.timeSlot = selectedTimeSlot!
    }
    
    static public func addCustomer(customer: Customer) {
        self.customers.append(customer)
    }
}
