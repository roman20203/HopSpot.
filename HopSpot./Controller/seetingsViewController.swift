import UIKit
import SwiftUI

// Define the SettingCellModel struct
struct SettingCellModel {
    let title: String
    let handler: (() -> Void)
}

final class seetingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    // Initialize the data array with SettingCellModel objects
    private var data = [[SettingCellModel]]()
    private let viewModel = log_in_view_model() // Assuming this is the shared instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Create a navigation bar with a back button and title
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let navItem = UINavigationItem(title: "Settings")
        
        // Create a back button
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBack))
        navItem.leftBarButtonItem = backButton
        
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
        
        // Adjust the table view frame to take up the full space below the navigation bar
        tableView.frame = CGRect(x: 0, y: navBar.frame.maxY, width: view.frame.width, height: view.frame.height - navBar.frame.height)
        
        // Add the table view to the main view
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds.offsetBy(dx: 0, dy: 44)
    }
    
    private func configureModels() {
        let section1 = [
            SettingCellModel(title: "About Us") {
                // Open the Invite Friends website
                if let url = URL(string: "https://www.hop-spot.ca/about") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            },
            SettingCellModel(title: "Terms of Service") {
                // Open the Terms of Service website
                if let url = URL(string: "https://www.hop-spot.ca/privacy-policy-1") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            },
            SettingCellModel(title: "Contact Us") {
                // Open the default mail app with the recipient email
                if let url = URL(string: "mailto:communications@hop-spot.ca") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        // Handle the error if the email app is unavailable
                        print("Email app is not available.")
                    }
                }
            },

            SettingCellModel(title: "Privacy Policy") {
                // Open the Privacy Policy website
                if let url = URL(string: "https://www.hop-spot.ca/privacy-policy-1") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        ]
        
        let section2 = [
            SettingCellModel(title: "Log Out") { [weak self] in
                self?.didTapLogOut()
            },
            SettingCellModel(title: "Delete Account") { [weak self] in
                self?.didTapDeleteAccount()
            }
        ]
        
        data.append(section1)
        data.append(section2)
    }

    
    private func didTapLogOut() {
        let alert = UIAlertController(title: "Log Out",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.signOut()
           //  self?.navigateToRegOrLogScreen()
        }))
        present(alert, animated: true)
    }
    
    private func didTapDeleteAccount() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Are you sure you want to delete your account? This action cannot be undone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { [weak self] _ in
            Task{
                await self?.viewModel.deleteAccount()
            }
        }))
        present(alert, animated: true)
    }
    
    private func navigateToRegOrLogScreen() {
        let regOrLogVC = UIHostingController(rootView: reg_or_log().environmentObject(viewModel))
        regOrLogVC.modalPresentationStyle = .fullScreen
        present(regOrLogVC, animated: true, completion: nil)
    }
}

extension seetingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        cell.textLabel?.textAlignment = .center // Center the text for a better look
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = data[indexPath.section][indexPath.row]
        model.handler()
    }
}

