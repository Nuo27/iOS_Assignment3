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
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var autoFetchButton: UIButton!
    // timer
    var timer = Timer()
    var fetchInterval: TimeInterval = 60
    var isOn = false
    var fetchMulti = 2
    var autoOnOff = false
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
    private let user = MySQLConfiguration(
        user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
        port: 3306, socket: "/mysql/mysql.sock")
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Call your function here
        BookingViewController.customers.removeAll()
        self.bookingTableView.reloadData()
        timer.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        autoFetchButton.isEnabled = false
        // timer
        timer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true) {
            timer in
            if self.isOn {
                //Methods called every seconds
                self.fetchData()
            }
        }
        timer.fire()
        //print(RIDs ?? [])
        // init as false if admin that need to select timeslot first
        if(isAdmin){
            refreshButton.isEnabled = false
            autoFetchButton.isEnabled = false
        }
        else{
            refreshButton.isEnabled = true
            autoFetchButton.isEnabled = true
            fetchData()
        }
        datePicker.isHidden = !isAdmin
        timeSlotButton.isHidden = !isAdmin
        //var
        selectedTimeSlot = nil
        deleteButton.isEnabled = false
        detailButton.isEnabled = false
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
        // date setup
        datePicker.minimumDate = Date()
        let maxDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())
        datePicker.maximumDate = maxDate
        viewingDate = getLocalDate(date: datePicker.date)
        if(isAdmin){
            let minDate = Calendar.current.date(byAdding: .day, value: -15, to: Date())
            datePicker.minimumDate = minDate
        }
        // Show loading indicator old old
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
        
    }
    //Auto fetch settings
    @IBAction func showAutoFetchSettings() {
        let settingsAlert = UIAlertController(title: "Auto Fetch Settings", message: nil, preferredStyle: .alert)
        
        // Create a vertical stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        // IsPaused Stack View
        let isOnStackView = UIStackView()
        isOnStackView.axis = .horizontal
        isOnStackView.spacing = 8
        
        let isOnLabel = UILabel()
        isOnLabel.text = "Auto Fetch:"
        isOnStackView.addArrangedSubview(isOnLabel)
        let isOnSwitch = UISwitch()
        isOnSwitch.isOn = isOn
        isOnSwitch.addTarget(self, action: #selector(isOnSwitchValueChanged(_:)), for: .valueChanged)
        isOnStackView.addArrangedSubview(isOnSwitch)
        
        stackView.addArrangedSubview(isOnStackView)
        // Fetch Interval Stack View
        let fetchIntervalStackView = UIStackView()
        fetchIntervalStackView.axis = .horizontal
        fetchIntervalStackView.spacing = 8
        
        let intervalLabel = UILabel()
        intervalLabel.text = "Every:"
        fetchIntervalStackView.addArrangedSubview(intervalLabel)
        
        let intervalValueLabel = UILabel()
        let formattedInterval = String(format: "%.0f", fetchInterval)
        intervalValueLabel.text = "\(formattedInterval)s"
        fetchIntervalStackView.addArrangedSubview(intervalValueLabel)
        
        let intervalStepper = UIStepper()
        intervalStepper.minimumValue = 2
        intervalStepper.maximumValue = 5
        intervalStepper.stepValue = 1
        intervalStepper.value = Double(fetchMulti)
        intervalStepper.addTarget(self, action: #selector(intervalStepperValueChanged(_:)), for: .valueChanged)
        fetchIntervalStackView.addArrangedSubview(intervalStepper)
        
        stackView.addArrangedSubview(fetchIntervalStackView)
        
        // Save Button
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(saveButton)
        
        // Cancel Button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(cancelButton)
        
        // Add the stack view to the alert controller's view
        settingsAlert.view.addSubview(stackView)
        
        // Add constraints for the stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: settingsAlert.view.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: settingsAlert.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: settingsAlert.view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: settingsAlert.view.bottomAnchor, constant: -16)
        ])
        
        // Present the settings alert
        present(settingsAlert, animated: true, completion: nil)
    }
    
    @objc func intervalStepperValueChanged(_ stepper: UIStepper) {
        let valueLabel = findValueLabel(for: stepper)
        fetchMulti = Int(stepper.value)
        let fi = TimeInterval(30 * fetchMulti)
        let formattedInterval = String(format: "%.0f", fi)
        valueLabel?.text = "\(formattedInterval)s"
    }
    
    @objc func isOnSwitchValueChanged(_ isOnSwitch: UISwitch) {
        autoOnOff = isOnSwitch.isOn
    }
    func findValueLabel(for control: UIControl) -> UILabel? {
        guard let stackView = control.superview as? UIStackView else {
            fatalError("Failed")
        }
        var j = 0
        for i in stackView.subviews {
            if let valueLabel = i as? UILabel {
                j += 1
                if j == 2 {
                    return valueLabel
                }
            }
        }
        
        return nil
    }
    @objc func saveButtonTapped() {
        print("Fetch Multi: \(fetchMulti)")
        print("On&Off: \(autoOnOff)")
        fetchInterval = TimeInterval(30 * fetchMulti)
        isOn = autoOnOff
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    // timer called function for auto fetching
    @objc func fetchData() {
        print("Fetching")
        fetchCustomer()
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
        let alertController = UIAlertController(
            title: "Fetching", message: "You are fetching booking records now",
            preferredStyle: .alert)
        
        let fetchAction = UIAlertAction(title: "Lets go!", style: .default) { _ in
            self.fetchCustomer()
        }
        alertController.addAction(fetchAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // added indicator
    func fetchCustomer(){

        // Disable user interaction while deleting
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
        
        DispatchQueue.main.async {
            if self.isAdmin{
                if self.adminFetchDataFromDatabase(viewingDate: self.viewingDate, selectedTimeSlot: self.selectedTimeSlot!) {
                    activityIndicator.stopAnimating()
                    containerView.removeFromSuperview()
                } else {
                    print("Failed to fetch customer")
                    
                    // Show error notification
                    let errorAlertController = UIAlertController(
                        title: "Error", message: "Failed to fetch customer.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    errorAlertController.addAction(okAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                }
            } else {
                if self.guestFetchDataFromDatabase(RIDs: self.RIDs!) {
                    activityIndicator.stopAnimating()
                    containerView.removeFromSuperview()
                } else {
                    print("Failed to fetch customer")
                    
                    // Show error notification
                    let errorAlertController = UIAlertController(
                        title: "Error", message: "Failed to fetch customer.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    errorAlertController.addAction(okAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                }
            }
            
            // Enable user interaction after complete
            self.view.isUserInteractionEnabled = true
            self.deleteButton.isEnabled = false
            self.detailButton.isEnabled = false
            activityIndicator.stopAnimating()
            containerView.removeFromSuperview()

        }
    }

    // show and select time slots in action sheet
    @objc func timeSlotButtonTapped() {
        let alertController = UIAlertController(title: "Select a Time", message: nil, preferredStyle: .actionSheet)
        
        for timeSlot in timeSlots {
            let action = UIAlertAction(title: timeSlot, style: .default) { _ in
                // Handle the selected time slot
                self.selectedTimeSlot = timeSlot
                print(self.selectedTimeSlot!)
                self.refreshButton.isEnabled = true
                self.autoFetchButton.isEnabled = true
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
    // display customer details in alert
    // this will never be called if not selected
    @IBAction func showDetailInAlert() {
        
        if let rid = selectedCustomer?.getRID(),
           let name = selectedCustomer?.getName(),
           let phoneNumber = selectedCustomer?.getPhoneNumber(),
           let emailAddress = selectedCustomer?.getEmailAddress(),
           let partySize = selectedCustomer?.getPartySize(),
           let timeSlot = selectedCustomer?.getTimeSlot(),
           let date = selectedCustomer?.getDate() {
            var message = ""
            if(isOutOfDate(inDate: date)){
                message = """
        --OUT OF DATE--
        RID: \(rid)
        Name: \(name)
        Phone Number: \(phoneNumber)
        Email Address: \(emailAddress)
        Party Size: \(partySize)
        Time Slot: \(timeSlot)
        Date: \(date)
        """
            }
            else{
                message = """
        --UPCOMING BOOKING--
        RID: \(rid)
        Name: \(name)
        Phone Number: \(phoneNumber)
        Email Address: \(emailAddress)
        Party Size: \(partySize)
        Time Slot: \(timeSlot)
        Date: \(date)
        """
            }

            let alertController = UIAlertController(title: "Your booking detail", message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okayAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    // delete customer
    // this will never be called if not selected
    @objc func deleteButtonTapped() {
        let alertController = UIAlertController(
            title: "Cancel Booking", message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteCustomer()
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // added indicator
    func deleteCustomer() {
        // Disable user interaction while deleting
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
        
        DispatchQueue.main.async {
            if self.databaseDeleteCustomer(customer: self.selectedCustomer!) {
                print("Successfully cancelled")
                
                // Show success notification
                let successAlertController = UIAlertController(
                    title: "Success", message: "Booking cancelled successfully.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                successAlertController.addAction(okAction)
                self.present(successAlertController, animated: true, completion: nil)
            } else {
                print("Failed to delete customer")
                
                // Show error notification
                let errorAlertController = UIAlertController(
                    title: "Error", message: "Failed to cancel booking.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlertController.addAction(okAction)
                self.present(errorAlertController, animated: true, completion: nil)
            }
            
            // Enable user interaction after deletion is complete
            self.view.isUserInteractionEnabled = true
            self.deleteButton.isEnabled = false
            self.detailButton.isEnabled = false
            
            // Remove the indicator
            containerView.removeFromSuperview()
        }
    }
    // remove Receipts from local
    func removeGuestRIDFromUserDefaults(_ rid: Int) {
        var guestRIDs = UserDefaults.standard.array(forKey: "rid") as? [Int] ?? []
        
        if let index = guestRIDs.firstIndex(of: rid) {
            guestRIDs.remove(at: index)
            UserDefaults.standard.set(guestRIDs, forKey: "rid")
        }
    }
    // delete customer records and return success message
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
                coordinator.disconnect()
                return adminFetchDataFromDatabase(viewingDate: viewingDate, selectedTimeSlot: selectedTimeSlot!)
            }
            else{
                coordinator.disconnect()
                return guestFetchDataFromDatabase(RIDs: RIDs!)
            }
        } catch {
            print("Cannot execute the query.")
            coordinator.disconnect()
            return false
        }
    }
    // check if a date String is out of date()today
    func isOutOfDate(inDate: String) -> Bool {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        if let date = dateFormatter.date(from: inDate) {
            let inputDate = Calendar.current.startOfDay(for: date)
            return inputDate < currentDate
        }
        
        return true // Return true if the input date cannot be parsed
    }
    // fetch data base on provided rids of guest user
    func guestFetchDataFromDatabase(RIDs: [Int]) -> Bool{
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
            bookingTableView.reloadData()
            print("Data fetched from the database.")
            coordinator.disconnect()
            return true
            
        } catch {
            print("Cannot execute the query.")
            coordinator.disconnect()
            return false
        }
    }
    // fetch all customer records based on date and timeslot
    func adminFetchDataFromDatabase(viewingDate: String, selectedTimeSlot: String) -> Bool{
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
            
            bookingTableView.reloadData()
            coordinator.disconnect()
            return true
            
        } catch {
            print("Cannot execute the query.")
            coordinator.disconnect()
            return false
        }
        
    }
    // dropped function 
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
        if(isOutOfDate(inDate: customer.getDate())){
            cell.textLabel?.textColor = .systemGray
        }
        else{
            cell.textLabel?.textColor = .black
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customer = BookingViewController.customers[indexPath.row]
        let selectedRID = customer.getRID() // Assuming you have a method to retrieve the RID
        if(isOutOfDate(inDate: customer.getDate())){
            deleteButton.setTitle("Delete", for: .normal)
        }
        else{
            deleteButton.setTitle("Cancel", for: .normal)
        }
        // Check if the selected customer is already selected
        if let selectedCustomer = selectedCustomer, selectedCustomer.getRID() == selectedRID {
            // Deselect the cell
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedCustomer = nil
            deleteButton.isEnabled = false
            detailButton.isEnabled = false
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
                detailButton.isEnabled = true
            }
        }
    }
}



