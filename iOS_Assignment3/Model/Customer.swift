//
//  Customer.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation

class Customer {
    private var name: String
    private var phoneNumber: String
    private var emailAddress: String
    private var partySize: Int
    private var timeSlot: String
    
    init(name: String, phoneNumber: String, emailAddress: String, partySize: Int, timeSlot: String) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.partySize = partySize
        self.timeSlot = timeSlot
    }
    
    // Getter methods
    func getName() -> String {
        return name
    }
    
    func getPhoneNumber() -> String {
        return phoneNumber
    }
    
    func getEmailAddress() -> String {
        return emailAddress
    }
    func getPartySize() -> Int{
        return partySize
    }
    func getTimeSlot() -> String{
        return timeSlot
    }
    
    // Setter methods
    func setName(name: String) {
        self.name = name
    }
    
    func setPhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    func setEmailAddress(emailAddress: String) {
        self.emailAddress = emailAddress
    }
    func setPartySize(partySize: Int){
        self.partySize = partySize
    }
    func setTimeSlot(timeSlot: String){
        self.timeSlot = timeSlot
    }
    
    
    func displayInformation() {
        print("Name: \(name)")
        print("Phone Number: \(phoneNumber)")
        print("Email Address: \(emailAddress)")
        print("PartySize: \(partySize)")
    }
}

