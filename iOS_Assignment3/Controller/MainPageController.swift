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
    var isAdmin: Bool = false
    var adminName: String = "admin"
    var adminPass: String = "admin"
    var currentCustomer = Customer(name: "Guest", phoneNumber: "", emailAddress: "", partySize: 1, timeSlot: "")
    
    //ui
    @IBOutlet weak var welcomeMessage:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        isAdmin = false
        // Do any additional setup after loading the view.
        updateWelcomeMessage()
        
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
        bookingView.isAdmin = isAdmin
        //bookingView.user = user
    }
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if isAdmin {
            showAccountManagementWindow()
        } else {
            showLoginWindow()
        }
    }
    
    func updateWelcomeMessage() {
            if isAdmin {
                welcomeMessage.text = "Welcome! Admin"
            } else {
                welcomeMessage.text = "Welcome! \(currentCustomer.getName())"
            }
        }
        
        func showLoginWindow() {
            let alert = UIAlertController(title: "Login", message: "Enter your account credentials", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Username"
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
                // Handle login action
                if let usernameField = alert.textFields?[0], let passwordField = alert.textFields?[1] {
                    let username = usernameField.text ?? ""
                    let password = passwordField.text ?? ""
                    
                    // Perform login authentication with the provided username and password
                    
                    // Example authentication logic
                    if username == self.adminName && password == self.adminPass {
                        self.isAdmin = true
                        self.showLoginSuccess()
                    } else {
                        // Authentication failed, display an error message
                        self.showLoginError()
                    }
                }
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        func showLoginError() {
            let alert = UIAlertController(title: "Login Failed", message: "Invalid username or password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            updateWelcomeMessage()
        }
        
        func showLoginSuccess() {
            let alert = UIAlertController(title: "Login Successfully", message: "Login successfully as a restaurant", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            updateWelcomeMessage()
        }
        
        func showAccountManagementWindow() {
            let alert = UIAlertController(title: "Account Management", message: "Manage your account", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Edit Account", style: .default, handler: { (_) in
                self.showEditAccountWindow()
            }))
            
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
                self.isAdmin = false
                self.showLogoutSuccess()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        
        func showEditAccountWindow() {
            let editAccountAlert = UIAlertController(title: "Edit Account", message: "Edit your account name and password", preferredStyle: .alert)
            
            editAccountAlert.addTextField { (textField) in
                textField.placeholder = "New Account Name"
            }
            
            editAccountAlert.addTextField { (textField) in
                textField.placeholder = "New Password"
                textField.isSecureTextEntry = true
            }
            
            editAccountAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            editAccountAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                // Handle account editing action
                if let accountNameField = editAccountAlert.textFields?[0], let passwordField = editAccountAlert.textFields?[1] {
                    let newAccountName = accountNameField.text ?? ""
                    let newPassword = passwordField.text ?? ""
                    
                    // Perform account editing logic
                    
                    // Example logic: Update the account name and password
                    if !newAccountName.isEmpty {
                        self.adminName = newAccountName
                    }
                    if !newPassword.isEmpty {
                        self.adminPass = newPassword
                    }
                    
                    // Show a success message
                    self.showEditAccountSuccess()
                }
            }))
            
            present(editAccountAlert, animated: true, completion: nil)
        }
        
        func showEditAccountSuccess() {
            let alert = UIAlertController(title: "Account Updated", message: "Your account has been updated successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        func showLogoutSuccess() {
            let alert = UIAlertController(title: "Logout", message: "You have been logged out", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            updateWelcomeMessage()
        }
}

