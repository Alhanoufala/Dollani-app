//
//  SignupViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 16/05/1444 AH.
//


import UIKit
import Firebase

class SignupViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signupClicked(_ sender: Any) {
        guard let email = email.text else {return}
        guard let password = password.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password){firebaseResult,error in
            if let e = error{
                print(e.localizedDescription)
            }
            else{
                self.performSegue(withIdentifier: "goToHomeScreen", sender: self)
            }
        }
    }
    
}
