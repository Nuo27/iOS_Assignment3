//
//  ViewBookingController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import UIKit

class BookingViewController: UIViewController {
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var bookButton: UIButton!
    let timeSlots = ["10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM"]
    var selectedTimeSlot: String?
    static var customers: [Customer] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        bookButton.isEnabled = false
        bookingTableView.dataSource = self
        bookingTableView.delegate = self
        
        // Register table view cell
        bookingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TimeSlotCell")
        
        // for debug
        BookingViewController.customers.append(Customer(name: "John Doe", phoneNumber: "1234567890", emailAddress: "johndoe@example.com", partySize: 2, timeSlot: "10:00 AM"))
        BookingViewController.customers.append(Customer(name: "Jane Smith", phoneNumber: "9876543210", emailAddress: "janesmith@example.com", partySize: 1, timeSlot: "3:00 PM"))
        
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

