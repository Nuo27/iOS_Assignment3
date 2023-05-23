//
//  ViewBookingController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import OHMySQL
import UIKit

class BookingViewController: UIViewController {
    
    //UI var
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeSlotButton: UIButton!
    //var
    
    var mostPartySize: Int = 0
    var isAdmin: Bool = false
    let timeSlots = [
        "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM",
        "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM"
    ]
    
    var viewingDate: String = ""
    var viewingTimeSlot: String = ""
    var selectedTimeSlot: String? {
        didSet {
            timeSlotButton.setTitle(selectedTimeSlot ?? "Select Time", for: .normal)
        }
    }
    var RIDs: [Int]? = []
    var selectedCustomer: Customer?
    static var customers: [Customer] = []
    //database config
    let user = MySQLConfiguration(
        user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
        port: 3306, socket: "/mysql/mysql.sock")
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Call your function here
        BookingViewController.customers.removeAll()
        self.bookingTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(RIDs ?? [])
        // init as false
        if(isAdmin){
            refreshButton.isEnabled = false
        }
        else{
            refreshButton.isEnabled = true
        }
        selectedTimeSlot = nil
        deleteButton.isEnabled = false
        // delegate
        bookingTableView.dataSource = self
        bookingTableView.delegate = self
        // target
        timeSlotButton.addTarget(self, action: #selector(timeSlotButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateValueChanged(_:)), for: .valueChanged)
        // button titles
        deleteButton.setTitle("Cancel", for: .normal)
        
        // Register table view cell
        bookingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TimeSlotCell")
        // add target to Buttons
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        //
        datePicker.minimumDate = Date()
        let maxDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())
        datePicker.maximumDate = maxDate
        viewingDate = getLocalDate(date: datePicker.date)
        // Show loading indicator
//        let activityIndicator = UIActivityIndicatorView(style: .medium)
//        activityIndicator.center = self.view.center
//        activityIndicator.startAnimating()
//        self.view.addSubview(activityIndicator)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            // Call the fetchDataFromDatabase function after a  delay
//            //self.fetchDataFromDatabase()
//
//            // Stop and remove the activity indicator
//            activityIndicator.stopAnimating()
//            activityIndicator.removeFromSuperview()
//        }
        
        
        datePicker.isHidden = !isAdmin
        timeSlotButton.isHidden = !isAdmin
        
    }
    func getLocalDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        // Set the time zone to the local time zone
        dateFormatter.timeZone = TimeZone.current
        
        let localTime = dateFormatter.string(from: date)
        return localTime
    }
    @objc func dateValueChanged(_ sender: UIDatePicker) {
        viewingDate = getLocalDate(date: sender.date)
    }
    @objc func refreshButtonTapped() {
        if (isAdmin) {
            adminFetchDataFromDatabase(viewingDate: viewingDate, selectedTimeSlot: selectedTimeSlot!)
        }
        else{
            guestFetchDataFromDatabase(RIDs: RIDs!)
        }
    }
    @objc func timeSlotButtonTapped() {
        let alertController = UIAlertController(title: "Select a Time", message: nil, preferredStyle: .actionSheet)
        
        for timeSlot in timeSlots {
            let action = UIAlertAction(title: timeSlot, style: .default) { _ in
                // Handle the selected time slot
                self.selectedTimeSlot = timeSlot
                print(self.selectedTimeSlot!)
                self.refreshButton.isEnabled = true
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = timeSlotButton
            popoverController.sourceRect = timeSlotButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }


    @objc func deleteButtonTapped() {
        let alertController = UIAlertController(
            title: "Cancel Booking", message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteCustomer()
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteCustomer() {
        // Disable user interaction while deleting
        view.isUserInteractionEnabled = false
        
        if databaseDeleteCustomer(customer: selectedCustomer!) {
            print("Successfully deleted")
            //fetchDataFromDatabase()
            
            // Show success notification
            let successAlertController = UIAlertController(
                title: "Success", message: "Customer deleted successfully.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            successAlertController.addAction(okAction)
            present(successAlertController, animated: true, completion: nil)
        } else {
            print("Failed to delete customer")
            
            // Show error notification
            let errorAlertController = UIAlertController(
                title: "Error", message: "Failed to delete customer.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlertController.addAction(okAction)
            present(errorAlertController, animated: true, completion: nil)
        }
        
        // Enable user interaction after deletion is complete
        view.isUserInteractionEnabled = true
        deleteButton.isEnabled = false
    }
    func removeGuestRIDFromUserDefaults(_ rid: Int) {
        var guestRIDs = UserDefaults.standard.array(forKey: "rid") as? [Int] ?? []
        
        if let index = guestRIDs.firstIndex(of: rid) {
            guestRIDs.remove(at: index)
            UserDefaults.standard.set(guestRIDs, forKey: "rid")
        }
    }
    
    func databaseDeleteCustomer(customer: Customer) -> Bool {
        let rid = customer.getRID()
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        if coordinator.connect() {
            print("Connected successfully")
        }
        let context = MySQLQueryContext()
        context.storeCoordinator = coordinator
        MySQLContainer.shared.mainQueryContext = context
        let deleteString =
        "DELETE FROM customer WHERE RID = '\(rid)';"
        let deleteRequest = MySQLQueryRequest(query: deleteString)
        do {
            try MySQLContainer.shared.mainQueryContext?.execute(deleteRequest)
            print("Customer deleted from the database.")
            removeGuestRIDFromUserDefaults(rid)
            if(isAdmin){
                adminFetchDataFromDatabase(viewingDate: viewingDate, selectedTimeSlot: selectedTimeSlot!)
            }
            else{
                guestFetchDataFromDatabase(RIDs: RIDs!)
            }
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

// MARK: - UITableViewDataSource
extension BookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BookingViewController.customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSlotCell", for: indexPath)
        let customer = BookingViewController.customers[indexPath.row]
        
        cell.textLabel?.text =
        "receipt \(customer.getRID()): booked by \(customer.getName()) (\(customer.getPartySize()))"
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customer = BookingViewController.customers[indexPath.row]
        let selectedRID = customer.getRID() // Assuming you have a method to retrieve the RID
        
        // Check if the selected customer is already selected
        if let selectedCustomer = selectedCustomer, selectedCustomer.getRID() == selectedRID {
            // Deselect the cell
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedCustomer = nil
            deleteButton.isEnabled = false
        } else {
            // Handle booking logic for the selected customer
            print("Selected RID: \(selectedRID)")
            
            if let customer = BookingViewController.customers.first(where: {
                $0.getRID() == selectedRID
            }) {
                print("Selected customer: \(customer.getName())")
                selectedCustomer = customer
                viewingDate = customer.getDate()
                selectedTimeSlot = customer.getTimeSlot()
                deleteButton.isEnabled = true
            }
        }
    }
}



