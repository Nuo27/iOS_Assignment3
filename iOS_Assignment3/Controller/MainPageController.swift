//
//  ViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 7/5/2023.
//

import UIKit
import OHMySQL
class MainPageController: UIViewController {
    let user = MySQLConfiguration(user: "grouphd",password: "grouphd1",serverName: "db4free.net",dbName: "iosgroupass",port: 3306,socket: "/mysql/mysql.sock")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // Testing database functionality
//        let coordinator = MySQLStoreCoordinator(configuration: user)
//        coordinator.encoding = .UTF8MB4
//
//
//        if coordinator.connect() {
//           print("Connected successfully.")
//        }
//        let context = MySQLQueryContext()
//        context.storeCoordinator = coordinator
//        MySQLContainer.shared.mainQueryContext = context
//
//        let insertString = "INSERT INTO customer (name, phoneNumber, emailAddress, partySize, timeSlot) VALUES ('John Doe', '1234567890', 'johndoe@example.com', 4, '1:00 PM');"
//        let insertRequest = MySQLQueryRequest(query: insertString)
//        do {
//            try MySQLContainer.shared.mainQueryContext?.execute(insertRequest)
//        } catch {
//            print("Cannot execute the query.")
//        }
//        let queryString = "SELECT * FROM customer"
//
//        let queryRequest = MySQLQueryRequest(query: queryString)
//        do {
//            let result = try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(queryRequest) ?? []
//            print("\(result)")
//        } catch {
//            print("Cannot execute the query.")
//        }
//
//        let deleteRequest = MySQLQueryRequest(query: "DELETE FROM customer WHERE partysize = '4'")
//
//        do {
//            try MySQLContainer.shared.mainQueryContext?.execute(deleteRequest)
//        } catch {
//            print("Cannot execute the query.")
//        }
//
//        do {
//            let result = try MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(queryRequest) ?? []
//            print("\(result)")
//        } catch {
//            print("Cannot execute the query.")
//        }
//        coordinator.disconnect()
//
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bookingView = segue.destination as! BookingViewController
        //bookingView.user = user
    }


}

