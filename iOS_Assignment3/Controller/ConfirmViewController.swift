//
//  ConfirmViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//


import Foundation
import UIKit
class ConfirmViewController: UIViewController {
    var cus: Customer? = nil
    @IBOutlet weak var confirmBtn: UIButton!
    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
            // Add target action to the confirm button
            confirmBtn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        }
        
        @objc func confirmButtonTapped() {
            BookingViewController.addCustomer(customer: cus!)
            if let navigationController = navigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }


}
