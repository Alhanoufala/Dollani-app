//
//  VIprofileViewController.swift
//  Dollani
//
//  Created by Sara on 18/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage

class VIprofileViewController: UIViewController {

    @IBOutlet weak var name: UITextView!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var phoneNum: UITextView!
    
    @IBOutlet weak var email: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePic?.layer.cornerRadius = (profilePic?.frame.size.width ?? 0.0) / 2
        profilePic?.clipsToBounds = true
        profilePic?.layer.borderWidth = 3.0
        profilePic?.layer.borderColor = UIColor.white.cgColor
        
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
                               let profilePicUrl = snapshot?.documents.first?.get("profilePhoto") as! String
                               //set profile pic
                               let storageRef = Storage.storage().reference(forURL: profilePicUrl)
                               storageRef.downloadURL(completion: { (url, error) in
                                   
                                   let data = NSData(contentsOf: url!)
                                   let image = UIImage(data: (data! as NSData) as Data)
                                   
                                   
                                   self.profilePic?.image = image
                               })
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
    
    
    @IBAction func editTapped(_ sender: Any) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "editProfile")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)

        
    }
    
    fileprivate func setupLogOutButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "تسجيل الخروج").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "تسجيل الخروج", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "selection")
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
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
