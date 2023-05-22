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
  @IBOutlet weak var bookButton: UIButton!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!
  //var
  var isAdmin: Bool = false
  let timeSlots = [
    "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM",
    "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM",
  ]
  var selectedTimeSlot: String?
  var selectedCustomer: Customer?
  static var customers: [Customer] = []
  //database config
  let user = MySQLConfiguration(
    user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
    port: 3306, socket: "/mysql/mysql.sock")

  override func viewDidLoad() {
    super.viewDidLoad()
    // init as false
    bookButton.isEnabled = false
    deleteButton.isEnabled = false
    // delegate
    bookingTableView.dataSource = self
    bookingTableView.delegate = self

    // button titles
    bookButton.setTitle("Book", for: .normal)
    deleteButton.setTitle("Cancel", for: .normal)

    // Register table view cell
    bookingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TimeSlotCell")
    // add target to Buttons
    refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    // for debug
    //        var customer1 = Customer(name: "John Doe", phoneNumber: "1234567890", emailAddress: "johndoe@example.com", partySize: 2, timeSlot: "10:00 AM")
    //        var customer2 = Customer(name: "Jane Smith", phoneNumber: "9876543210", emailAddress: "janesmith@example.com", partySize: 1, timeSlot: "3:00 PM")
    //        databaseCreateCustomer(customer: customer1)
    //        databaseCreateCustomer(customer: customer2)
    // Show loading indicator
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.center = self.view.center
    activityIndicator.startAnimating()
    self.view.addSubview(activityIndicator)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      // Call the fetchDataFromDatabase function after a  delay
      self.fetchDataFromDatabase()

      // Stop and remove the activity indicator
      activityIndicator.stopAnimating()
      activityIndicator.removeFromSuperview()
    }

    print(isAdmin)
  }
  @objc func refreshButtonTapped() {
    fetchDataFromDatabase()
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
      fetchDataFromDatabase()

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

  func fetchDataFromDatabase() {
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

    let selectString = "SELECT * FROM customer;"
    let selectRequest = MySQLQueryRequest(query: selectString)

    DispatchQueue.global(qos: .userInitiated).async { [weak self, weak activityIndicator] in
      guard let self = self else { return }

      do {
        let result =
          try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(
            selectRequest) ?? []
        BookingViewController.customers.removeAll()

        for row in result {
          if let name = row["name"] as? String,
            let phoneNumber = row["phonenumber"] as? String,
            let emailAddress = row["emailaddress"] as? String,
            let partySize = row["partysize"] as? Int,
            let timeSlot = row["timeslot"] as? String
          {
            let customer = Customer(
              name: name, phoneNumber: phoneNumber, emailAddress: emailAddress,
              partySize: partySize, timeSlot: timeSlot)

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
    return timeSlots.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSlotCell", for: indexPath)
    let timeSlot = timeSlots[indexPath.row]

    // Find the customer for this time slot
    if let customer = BookingViewController.customers.first(where: { $0.getTimeSlot() == timeSlot })
    {
      cell.textLabel?.text = "\(customer.getName()) (\(customer.getPartySize())"
    } else {
      cell.textLabel?.text = timeSlot  // Display the time slot if no customer is assigned
    }

    return cell
  }
}

// MARK: - UITableViewDelegate
extension BookingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedTimeSlot = timeSlots[indexPath.row]
    // Handle booking logic for the selected time slot
    print("Selected time slot: \(selectedTimeSlot ?? "")")

    if let customer = BookingViewController.customers.first(where: {
      $0.getTimeSlot() == selectedTimeSlot
    }) {
      print("Selected customer: \(customer.getName())")
      selectedCustomer = customer
      bookButton.isEnabled = false
      deleteButton.isEnabled = true

    } else {
      print("No Customer in this time slot")
      bookButton.isEnabled = true
      deleteButton.isEnabled = false
    }
  }
}
