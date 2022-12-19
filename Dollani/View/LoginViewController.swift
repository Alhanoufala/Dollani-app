//
//  ViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 15/05/1444 AH.
//

import UIKit
import Firebase
class LoginViewController: UIViewController , UITextFieldDelegate {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var showHideLabel: UIButton!
    
    var passwordVisible: Bool = true
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.textAlignment = .right
        email.textAlignment = .right
        
        password.delegate = self
        email.delegate = self

        configureView()
        


        
        // Do any additional setup after loading the view.
    }

    @IBAction func loginClicked(_ sender: Any) {
        guard let email = email.text else {return}
        guard let password = password.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password){firebaseResult,error in
            if let e = error{
                print(e.localizedDescription)
                //Alert message
                  let sendMailErrorAlert = UIAlertController(title: "خطاء", message: "البريد الإلكتروني أو كلمة المرور غير صحيحة", preferredStyle: .alert)
                      let cancelAction = UIAlertAction(title:"تم", style: .cancel, handler: nil)

                      sendMailErrorAlert.addAction(cancelAction)
                  self.present(sendMailErrorAlert, animated: true, completion: nil)
              
            }
            else{
                //check
                let q = self.db.collection("users").whereField("email", isEqualTo: email).whereField("category", isEqualTo: "ذوي اعاقة بصرية")
                
                if q != nil {
                    self.performSegue(withIdentifier: "GoToCGHomePage", sender: self)
                    
                }
                else {
                    self.performSegue(withIdentifier: "GoToVIHomePage", sender: self)}
            }
        }
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let vc = storyboard.instantiateViewController(identifier: "SignUp")
           vc.modalPresentationStyle = .overFullScreen
           present(vc, animated: true)
       }
    
    
    
    @IBAction func forgetpassword(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "resetPassword")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
     
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //toggle between show and hide password
    func configureView(){
            password.isSecureTextEntry = true
            password.clearsOnBeginEditing = false
            showHideLabel.setImage(UIImage(named: "icons8-hide-48"), for: .normal)
        }
    
    @IBAction func showHide() {
            if passwordVisible {
                password.isSecureTextEntry = false
                showHideLabel.setImage(UIImage(named: "icons8-eye-48"), for: .normal)
                passwordVisible = false
            } else {
                password.isSecureTextEntry = true
                showHideLabel.setImage(UIImage(named: "icons8-hide-48"), for: .normal)
                passwordVisible = true
            }
        }
    
    
}
