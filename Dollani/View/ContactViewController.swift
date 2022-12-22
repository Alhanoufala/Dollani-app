//
//  ContactViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 28/05/1444 AH.
//

import UIKit
import Firebase

class ContactViewController: UIViewController,ObservableObject {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddVI(_ sender: Any) {
        // create the actual alert controller view that will be the pop-up
        let alertController = UIAlertController(title: "اضافة جهة اتصال جديدة", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "الايميل"
        }
      
        
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "الغاء", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "اضافة", style: .default) { _ in
            let user = Auth.auth().currentUser
            
            let VIemail = alertController.textFields![0].text!
            let CGemail = user?.email
            // this code runs when the user hits the "save" button
            Firestore.firestore().collection("users").document(VIemail).setData(["CGEmail": CGemail!], merge: true) { error in
                if  error != nil {
                    print(error!.localizedDescription)
                }
                else{
                    print("it works")
                }
                
                
                
                
                
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
        
        
        
    }}
