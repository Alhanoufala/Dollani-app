//
//  EditCGprofileViewController.swift
//  Dollani
//
//  Created by Sara on 26/12/2022.
//

import UIKit
import Firebase

class EditCGprofileViewController: UIViewController,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    
    var name: String?

/*
    @IBOutlet weak var name: UITextView!
    
    
    @IBOutlet weak var phoneNum: UITextView!
    
    @IBOutlet weak var email: UITextView!
 */
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        /*
        name.textAlignment = .right
        phoneNum.textAlignment = .right
        email.textAlignment = .right
        */
        retriveUserInfo()
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
                            
                               self.name = snapshot?.documents.first?.get("name") as? String
                               let userPhoneNum = snapshot?.documents.first?.get("phoneNum") as! String
                               let userEmail = snapshot?.documents.first?.get("email") as! String
                               
                               /*
                               //Set textView
                               self.name.text = userName
                               self.phoneNum.text = userPhoneNum
                               self.email.text = userEmail
                                */
                           }
                       }
                   }
       
          // ...
        }
               
       
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    
   
   
    @IBAction func nameField(_ sender: Any) {
       // TextField("", text: name)
    }
    
    
   
    @IBAction func phone(_ sender: Any) {    }
    
    @IBAction func emailField(_ sender: Any) {
    }
   
    

    @IBAction func saveTapped(_ sender: Any) {
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "CGcontainer")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CGcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    

    
    // Do any additional setup after loading the view.
    }
