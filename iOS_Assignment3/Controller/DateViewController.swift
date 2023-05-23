//
//  DateViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 23/5/2023.
//

import Foundation
import UIKit
import OHMySQL
class DateViewController: UIViewController {

    // ui
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeSlotButton: UIButton!
    @IBOutlet weak var checkAvailbilityButton: UIButton!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    // var
    var isAdmin = false
    var currentTotalPartySize: Int = 0
    var mostAvailableSeats: Int = 0
    let user = MySQLConfiguration(
        user: "grouphd", password: "grouphd1", serverName: "db4free.net", dbName: "iosgroupass",
        port: 3306, socket: "/mysql/mysql.sock")
    var selectedTimeSlot: String? {
        didSet {
            timeSlotButton.setTitle(selectedTimeSlot ?? "Select Time", for: .normal)
        }
    }
    var isAvailable = false
    var selectedDate: String = ""
    let timeSlots = [
        "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM",
        "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM",
    ]
    let timeSlotsCapacity = 30
    override func viewDidLoad() {
        super.viewDidLoad()
        print(isAdmin)
        // var
        selectedTimeSlot = nil
        bookButton.isEnabled = false
        
        // title
        bookButton.setTitle("Book", for: .normal)
        checkAvailbilityButton.setTitle("Check", for: .normal)
        // set up target
        timeSlotButton.addTarget(self, action: #selector(timeSlotButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateValueChanged(_:)), for: .valueChanged)
        checkAvailbilityButton.isEnabled = false
        checkAvailbilityButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        datePicker.minimumDate = Date()
        let maxDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())
        datePicker.maximumDate = maxDate
        selectedDate = getLocalDate(date: datePicker.date)
    }
    @objc func dateValueChanged(_ sender: UIDatePicker) {
        selectedDate = getLocalDate(date: sender.date)
    }
    @objc func checkButtonTapped() {
        view.isUserInteractionEnabled = false
        getSumPartySizeFromDB(date: selectedDate, timeSlot: selectedTimeSlot!) { totalPartySize in
            print("Total party size: \(totalPartySize)")
            self.mostAvailableSeats = self.timeSlotsCapacity-totalPartySize
            self.messageLabel.text = "Selecting \(self.selectedTimeSlot!) on \(self.selectedDate), \(self.mostAvailableSeats) seats are available."
            if(self.mostAvailableSeats > 0){
                self.isAvailable = true
                self.bookButton.isEnabled = true
            }
            else{
                self.isAvailable = false
                self.mostAvailableSeats = 0
                self.bookButton.isEnabled = false
            }
        }
    }
    @objc func timeSlotButtonTapped() {
        let alertController = UIAlertController(title: "Select a Time", message: nil, preferredStyle: .actionSheet)
        
        for timeSlot in timeSlots {
            let action = UIAlertAction(title: timeSlot, style: .default) { _ in
                // Handle the selected time slot
                self.selectedTimeSlot = timeSlot
                self.checkAvailbilityButton.isEnabled = true
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
    func getLocalDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        // Set the time zone to the local time zone
        dateFormatter.timeZone = TimeZone.current
        
        let localTime = dateFormatter.string(from: date)
        return localTime
    }
    func getSumPartySizeFromDB(date: String, timeSlot: String, completion: @escaping (Int) -> Void) {
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        let coordinator = MySQLStoreCoordinator(configuration: user)
        coordinator.encoding = .UTF8MB4
        
        if coordinator.connect() {
            print("Connected successfully in fetching data")
            
            let context = MySQLQueryContext()
            context.storeCoordinator = coordinator
            MySQLContainer.shared.mainQueryContext = context
            
            let selectString = "SELECT SUM(partysize) AS totalPartySize FROM customer WHERE date = '\(date)' AND timeslot = '\(timeSlot)';"
            let selectRequest = MySQLQueryRequest(query: selectString)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self, weak activityIndicator] in
                guard let self = self else { return }
                
                do {
                    let result = try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(selectRequest) ?? []
                    
                    var totalPartySizeForTimeSlot = 0
                    
                    if let row = result.first,
                       let totalPartySize = row["totalPartySize"] as? Int {
                        totalPartySizeForTimeSlot = totalPartySize
                    }
                    
                    print("Data fetched from the database.")
                    
                    DispatchQueue.main.async {
                        // Hide loading indicator
                        activityIndicator?.stopAnimating()
                        activityIndicator?.removeFromSuperview()
                        
                        // Call the completion handler with the fetched result
                        completion(totalPartySizeForTimeSlot)
                        self.view.isUserInteractionEnabled = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        // Hide loading indicator
                        activityIndicator?.stopAnimating()
                        activityIndicator?.removeFromSuperview()
                        
                        print("Cannot execute the query.")
                        
                        // Call the completion handler with a default value or error indicator
                        completion(0)
                        self.view.isUserInteractionEnabled = true
                    }
                }
                
                coordinator.disconnect()
                
            }
        } else {
            print("Failed to connect to the database.")
            
            // Call the completion handler with a default value or error indicator
            completion(0)
            view.isUserInteractionEnabled = true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let customerDetailView = segue.destination as! CustomerDetailViewController
        customerDetailView.mostPartySize = mostAvailableSeats
        customerDetailView.isEditingRecord = false
        customerDetailView.timeSlot = selectedTimeSlot!
        customerDetailView.selectedDate = selectedDate
        
    }


}
