//
//  VIprofileViewController.swift
//  Dollani
//
//  Created by Sara on 18/12/2022.
//

import UIKit
import Firebase

class VIprofileViewController: UIViewController {

    @IBOutlet weak var name: UITextView!
    
    
    @IBOutlet weak var phoneNum: UITextView!
    
    @IBOutlet weak var email: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.textAlignment = .right
        phoneNum.textAlignment = .right
        email.textAlignment = .right
        
        retriveUserInfo()
        setupLogOutButton()
    }
    func retriveUserInfo(){
        let user = Auth.auth().currentUser
        if let user = user {
        
          let currentEmail = user.email
            print(currentEmail! )
            Firestore.firestore().collection("users").whereField("email",isEqualTo:currentEmail!).getDocuments { snapshot, error in
                if  error != nil {
                           // ERROR
                       }
                       else {
                           if(snapshot?.count != 0){
                            
                               let userName = snapshot?.documents.first?.get("name") as! String
                               let userPhoneNum = snapshot?.documents.first?.get("phoneNum") as! String
                               let userEmail = snapshot?.documents.first?.get("email") as! String
                               
                               //Set textView
                               self.name.text = userName
                               self.phoneNum.text = userPhoneNum
                               self.email.text = userEmail
                           }
                       }
                   }
       
          // ...
        }
               
       
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
