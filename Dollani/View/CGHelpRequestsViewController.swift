//
//  CGHelpRequestsViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 30/05/1444 AH.
//

import UIKit
import Firebase

class CGHelpRequestsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @Published var HelpRequests = [HelpRequest]()
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func fetchData() {
        let user = Auth.auth().currentUser
        let CGEmail = user?.email
        
        
        Firestore.firestore().collection("helpRequests").whereField("CGEmail", isEqualTo: CGEmail!).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.HelpRequests = documents.map { (queryDocumentSnapshot) -> HelpRequest in
                let data = queryDocumentSnapshot.data()
                let CGEmail = data["CGEmail"] as? String ?? ""
                let CGName = data["CGName"] as? String ?? ""
                let CGPhoneNum = data["CGPhoneNum"] as? String ?? ""
                let VIEmail = data["VIEmail"] as? String ?? ""
                let VIPhoneNum = data["VIPhoneNum"] as? String ?? ""
                let VIName = data["VIName"] as? String ?? ""
                let status = data["status"] as? String ?? ""
                
                
                return HelpRequest(CGEmail: CGEmail, CGName: CGName,CGPhoneNum: CGPhoneNum,VIEmail:VIEmail,VIName:VIName,VIPhoneNum:VIPhoneNum,status:status)
            }
            self.tableView.reloadData()
        }
        
    }
    @objc
    func videoCallButtonTapped(sender:UIButton){
        let rowIndex = sender.tag
       //Perform the call
        let VIPhoneNum = HelpRequests[rowIndex].VIPhoneNum
        if let url = URL(string: "facetime://" + VIPhoneNum ){
            UIApplication.shared.open(url,options: [:],completionHandler: nil)
         

        }
       
            
            
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CGHelpRequestsViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell tapped")
    }
}

extension CGHelpRequestsViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HelpRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpRequestCell", for: indexPath) as! HelpRequestTableViewCell
       
        cell.videoCallButton?.tag = indexPath.row
        cell.videoCallButton?.addTarget(self, action: #selector(videoCallButtonTapped), for: .touchUpInside)
        cell.textLabel?.textAlignment = .right

   
        cell.textLabel?.text = "قام " + HelpRequests[indexPath.row].VIName + " بارسال طلب مساعدة"
        return cell
    }
}

