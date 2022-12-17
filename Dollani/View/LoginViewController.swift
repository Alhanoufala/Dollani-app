//
//  ViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 15/05/1444 AH.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func loginClicked(_ sender: Any) {
        guard let email = email.text else {return}
        guard let password = password.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password){firebaseResult,error in
            if let e = error{
                print(e.localizedDescription)
                self.performSegue(withIdentifier: "GoToLoginError", sender: self)
            }
            else{
                //check
                let q = self.db.collection("users").whereField("email", isEqualTo: email).whereField("category", isEqualTo: "ذوي اعاقة بصرية")
                
                if q != nil {
                    self.performSegue(withIdentifier: "GoToVIHomePage", sender: self)
                }
                else {
                    self.performSegue(withIdentifier: "GoToCGHomePage", sender: self)}
            }
        }
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let vc = storyboard.instantiateViewController(identifier: "SignUp")
           vc.modalPresentationStyle = .overFullScreen
           present(vc, animated: true)
       }
    
    
    
    
    
}

