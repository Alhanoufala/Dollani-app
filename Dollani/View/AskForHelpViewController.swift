//
//  AskForHelpViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 29/05/1444 AH.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class AskForHelpViewController: UIViewController,ObservableObject,UINavigationBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @Published var CGUsers = [User]()
    var CGEmailList = [String] ()
    var VIPhoneNum = ""
    var VIName = ""
    var VIProfilePhoto = ""
    override func viewWillAppear(_ animated: Bool) {
        getCGEmails()
      
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate =  self
        tableView.dataSource = self
        navBar.delegate = self
        
        
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
                VIProfilePhoto =  snapshot?.documents.first?.get("profilePhoto") as! String
                fetchData()
                
                
                
                
            }
            
            
        }
    }
    
    
    
    
    func fetchData() {
        print(CGEmailList)
        if(CGEmailList.count != 0){
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
                    
                    let fcmToken =  data["fcmToken"] as? String ?? ""
                    let profilePic = data["profilePhoto"] as? String ?? ""
                    return User(name: name, email: email,phoneNum: phoneNum,category:category,fcmToken: fcmToken,profilePhoto:profilePic)
                }
                self.tableView.reloadData()
            }
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
        var token = ""
        print(CGEmail + "email")
        Firestore.firestore().collection("users").whereField("email",isEqualTo:CGEmail).getDocuments { snapshot, error in
                   if  error != nil {
                       print(error!.localizedDescription)
                   }
               
                   else{
                       token = snapshot?.documents.first?.get("fcmToken") as? String ?? ""
                       let sender = PushNotificationSender()
                      
                      sender.sendPushNotification(to:token, title: "دلني", body: "قام احد جهات الاتصال بارسال طلب مساعدة ")
                   }
               }

      
        Firestore.firestore().collection("helpRequests").document(VIEmail!+"-"+CGEmail).setData(["CGName" : CGName,"CGEmail":CGEmail,"CGPhoneNum":CGPhoneNum,"VIEmail":VIEmail!,"VIName":VIName,"VIPhoneNum":VIPhoneNum,"status":"new","VIProfilePhoto":VIProfilePhoto])
            
         //alert
        let alert = UIAlertController(title: nil, message:"تم ارسال الطلب بنجاج", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
       present(alert, animated: true, completion: nil)
            
            
        }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    }
    

extension AskForHelpViewController : UITableViewDelegate{
   
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellVi", for: indexPath) as! AskForhelpTableViewCell
       
        

        cell.askForHelpLabel?.text = CGUsers[indexPath.row].name
        
        if let  url = CGUsers[indexPath.row].profilePhoto{
            let storageRef = Storage.storage().reference(forURL: url)
            storageRef.downloadURL(completion: { (url, error) in
                
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: (data! as NSData) as Data)
                
              
                cell.profilePic.image = image
                
            })}
        return cell
    }
    
}

