//
//  CustomerDetailViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 16/5/2023.
//

import Foundation
import UIKit

class CustomerDetailViewController: UIViewController {
    var timeSlot: String = ""
    @IBOutlet weak var timeSlotTestLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timeSlotTestLabel.text = timeSlot
    }


}
