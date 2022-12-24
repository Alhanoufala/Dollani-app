//
//  AskForHelpViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 29/05/1444 AH.
//

import Foundation
import UIKit
import Firebase

class AskForHelpViewController: UIViewController,ObservableObject {
    
    @IBOutlet weak var tableView: UITableView!
    @Published var CGUsers = [User]()
    var CGEmailList = [String] ()
    var VIPhoneNum = ""
    var VIName = ""
    override func viewWillAppear(_ animated: Bool) {
        getCGEmails()
      
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate =  self
        tableView.dataSource = self
        
        
        
    }
    
    func getCGEmails() {
        let user = Auth.auth().currentUser
        let VIEmail = user?.email
        
        //get the CG emails
        Firestore.firestore().collection("users").whereField("email",isEqualTo:VIEmail!).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
              CGEmailList = snapshot?.documents.first?.get("CGEmail") as! [String]
                print(CGEmailList)
                VIPhoneNum = snapshot?.documents.first?.get("phoneNum") as! String
                VIName = snapshot?.documents.first?.get("name") as! String
               
                fetchData()
                
                
                
                
            }
            
            
        }
    }
    
    
    
    
    func fetchData() {
        print(CGEmailList)
        
        Firestore.firestore().collection("users").whereField("email", in: CGEmailList).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.CGUsers = documents.map { (queryDocumentSnapshot) -> User in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let phoneNum = data["phoneNum"] as? String ?? ""
                let category = data["category"] as? String ?? ""
                
                
                return User(name: name, email: email,phoneNum: phoneNum,category:category)
            }
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    @objc
    func sendHelpButtonTapped(sender:UIButton){
        let rowIndex = sender.tag
        let user = Auth.auth().currentUser
   
        //get the request info
        let CGName = CGUsers[rowIndex].name
        let CGEmail = CGUsers[rowIndex].email
        let CGPhoneNum = CGUsers[rowIndex].phoneNum
        let VIEmail =  user?.email
       
        Firestore.firestore().collection("helpRequests").document(VIEmail!+"-"+CGEmail).setData(["CGName" : CGName,"CGEmail":CGEmail,"CGPhoneNum":CGPhoneNum,"VIEmail":VIEmail!,"VIName":VIName,"VIPhoneNum":VIPhoneNum,"status":"new"])
            
         //alert
        let alert = UIAlertController(title: nil, message:"تم ارسال الطلب بنجاج", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
       present(alert, animated: true, completion: nil)
            
            
        }
    }
    

extension AskForHelpViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell tapped")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension AskForHelpViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        CGUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellVi", for: indexPath) as! CustomTableViewCell
       
        
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = CGUsers[indexPath.row].name
        cell.sendHelp?.tag = indexPath.row
        cell.sendHelp?.addTarget(self, action: #selector(sendHelpButtonTapped), for: .touchUpInside)
        return cell
    }
    
}

