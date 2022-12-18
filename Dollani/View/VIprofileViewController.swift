//
//  VIprofileViewController.swift
//  Dollani
//
//  Created by Sara on 18/12/2022.
//

import UIKit
import Firebase

class VIprofileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogOutButton()
    }
    
    fileprivate func setupLogOutButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Logout").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "تسجيل الخروج", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "GoToSelection", sender: self)
                //what happens? we need to present some kind of login controller
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "تراجع", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Do any additional setup after loading the view.
    }
