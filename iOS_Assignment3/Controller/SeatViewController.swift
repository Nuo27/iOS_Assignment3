//
//  SeatViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import UIKit

class SeatViewController: UIViewController {
    var timeSlot: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var partySize: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextView = segue.destination as! ConfirmViewController
        nextView.timeSlot = timeSlot
        nextView.firstname = firstname
        nextView.lastname = lastname
        nextView.phoneNumber = phoneNumber
        nextView.emailAddress = emailAddress
        nextView.partySize = partySize
    }
    
}

