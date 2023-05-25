//
//  ViewController.swift
//  iOS_Assignment3
//
//  Created by Nuo Chen on 7/5/2023.
//

import OHMySQL
import UIKit

class MainPageController: UIViewController {
    // var
    var isAdmin: Bool = false
    var adminName: String = "admin"
    var adminPass: String = "admin"
    //for current customer info display
//    static var currentCustomer = Customer(
//        rid: 0, name: "Customer", phoneNumber: "", emailAddress: "", partySize: 1, timeSlot: "", date: "")
    // debug
    static var currentCustomer = Customer(
        rid: 99, name: "Nuo chen", phoneNumber: "1234567890", emailAddress: "nuo@test.com", partySize: 5, timeSlot: "", date: "")
    
    //ui
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var accBtn: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Call your function here
        updateWelcomeMessage()
    }
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
    // get Receipt ID stored locally
    func retrieveGuestRIDFromUserDefault() -> [Int]? {
        return UserDefaults.standard.array(forKey: "rid") as? [Int] ?? []
    }
    // show options to display or clear local history receipt
    @IBAction func settingButtonPressed() {
        let alertController = UIAlertController(title: "Setting", message: nil, preferredStyle: .actionSheet)
        
        let printRIDAction = UIAlertAction(title: "Print All History Receipt IDs", style: .default) { _ in
            if let message = self.printRID() {
                self.showAlert(title: "My booking", message: message)
            }
        }
        alertController.addAction(printRIDAction)
        
        let clearRIDAction = UIAlertAction(title: "Clear All History Receipts", style: .destructive) { _ in
            self.showConfirmationAlert(message: "Are you sure you want to clear the local receipt? You will not be able to retrieve them any more! ", confirmHandler: { _ in
                self.clearRID()
                self.showAlert(title: "Clear Local",message: "Receipts cleared successfully.")
            })
        }
        alertController.addAction(clearRIDAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true, completion: nil)
    }
    // output receipt id message
    func printRID() -> String? {
        guard let rid = retrieveGuestRIDFromUserDefault() else {
            return "No receipt is found."
        }
        return "Your history booking receipt ID is/are: \(rid)"
    }
    // clear all rid
    func clearRID() {
        UserDefaults.standard.removeObject(forKey: "rid")
        UserDefaults.standard.synchronize()
    }
    // show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // show confirmation alert separately
    func showConfirmationAlert(message: String, confirmHandler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive, handler: confirmHandler)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // just for debug
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dateView = segue.destination as! DateViewController
        dateView.isAdmin = isAdmin
        dateView.previousCustomer = MainPageController.currentCustomer
    }
    // navigate to book view and pass values
    @IBAction func navigateToBookView(){
        let bookView = self.storyboard?.instantiateViewController(withIdentifier: "BookingView") as! BookingViewController
        if(isAdmin){
            bookView.isAdmin = isAdmin
        } else{
            bookView.RIDs = retrieveGuestRIDFromUserDefault() ?? []
        }
        self.navigationController?.pushViewController(bookView, animated: true)
        
    }
    // show login windows or management windows
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if isAdmin {
            showAccountManagementWindow()
        } else {
            showLoginWindow()
        }
    }
    // show the welcome message
    func updateWelcomeMessage() {
        if isAdmin {
            welcomeMessage.text = "Welcome! Admin"
            accBtn.setTitle("Staff", for: .normal)
        } else {
            welcomeMessage.text = "Welcome! \(MainPageController.currentCustomer.getName())"
            accBtn.setTitle("Guest", for: .normal)
        }
    }
    // display login window and allows login with username and password
    // this method will show a log: Changing the translatesAutoresizingMaskIntoConstraints property of a UICollectionViewCell that is managed by a UICollectionView is not supported, and will result in incorrect self-sizing.
    // but result is all fine
    // https://developer.apple.com/forums/thread/707150
    // similar situation not solved either
    func showLoginWindow() {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
        let alert = UIAlertController(
            title: "Login", message: "Enter your account credentials", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(
            UIAlertAction(
                title: "Login", style: .default,
                handler: { (_) in
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
    // fail to login message
    func showLoginError() {
        let alert = UIAlertController(
            title: "Login Failed", message: "Invalid username or password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        updateWelcomeMessage()
    }
    // login success messgae
    func showLoginSuccess() {
        let alert = UIAlertController(
            title: "Login Successfully", message: "Login successfully as a restaurant",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        updateWelcomeMessage()
    }
    // management windows with edit, logout and cancel
    func showAccountManagementWindow() {
        let alert = UIAlertController(
            title: "Account Management", message: "Manage your account", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(
                title: "Edit Account", style: .default,
                handler: { (_) in
                    self.showEditAccountWindow()
                }))
        
        alert.addAction(
            UIAlertAction(
                title: "Logout", style: .destructive,
                handler: { (_) in
                    self.isAdmin = false
                    self.showLogoutSuccess()
                }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    //edit new admin name and password
    func showEditAccountWindow() {
        let editAccountAlert = UIAlertController(
            title: "Edit Account", message: "Hi, \(self.adminName). Please Edit your account name and password", preferredStyle: .alert)
        
        editAccountAlert.addTextField { (textField) in
            textField.placeholder = "New Account Name"
            textField.text = self.adminName
        }
        
        editAccountAlert.addTextField { (textField) in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        
        editAccountAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        editAccountAlert.addAction(
            UIAlertAction(
                title: "Save", style: .default,
                handler: { (_) in
                    // Handle account editing action
                    if let accountNameField = editAccountAlert.textFields?[0],
                       let passwordField = editAccountAlert.textFields?[1]
                    {
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
    // edit success
    func showEditAccountSuccess() {
        let alert = UIAlertController(
            title: "Account Updated", message: "Your account has been updated successfully",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // logout success
    func showLogoutSuccess() {
        let alert = UIAlertController(
            title: "Logout", message: "You have been logged out", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        updateWelcomeMessage()
    }
}

