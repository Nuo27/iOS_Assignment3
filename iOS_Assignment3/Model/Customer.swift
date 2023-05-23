//
//  Customer.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation

class Customer {
    private var rid: Int
    private var name: String
    private var phoneNumber: String
    private var emailAddress: String
    private var partySize: Int
    private var timeSlot: String
    private var date: String
    
    init(rid: Int, name: String, phoneNumber: String, emailAddress: String, partySize: Int, timeSlot: String, date: String) {
        self.rid = rid
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.partySize = partySize
        self.timeSlot = timeSlot
        self.date = date
    }
    
    // Getter methods
    func getRID() -> Int{
        return rid
    }
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
    func getDate() -> String{
        return date
    }
    
    // Setter methods
    func setRID(rid: Int){
        self.rid = rid
    }
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
    func setDate(date: String){
        self.date = date
    }
}

