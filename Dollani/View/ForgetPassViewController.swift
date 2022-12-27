//
//  ForgetPassViewController.swift
//  Dollani
//
//  Created by Raseel AlRowais on 18/12/2022.
//

import UIKit
import Firebase

class ForgetPassViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SignUp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    @IBAction func forgetpassword(_ sender: Any) {
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: email.text!) { (error)  in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "لم تدخل بريدك الالكتروني بالشكل الصحيح", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "حسنًا", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            let alert = UIAlertController(title: "Success", message: "تم ارسال الرابط لبريدك الالكتروني", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "حسنًا", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            
            //        { (error) in
            //                   if let error = error {
            //                       let alert = Service.createAlertController(title: "Error", message: error.localizedDescription)
            //                       self.present(alert, animated: true, completion: nil)
            //                       return
            //                   }
            //
            //                   let alert = Service.createAlertController(title: "Hurray", message: "A password reset email has been sent!")
            //                   self.present(alert, animated: true, completion: nil)
            //               }
        }
    }
}
