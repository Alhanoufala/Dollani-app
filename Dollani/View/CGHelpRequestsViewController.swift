//
//  CGHelpRequestsViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 30/05/1444 AH.
//

import UIKit
import Firebase
import FirebaseStorage

class CGHelpRequestsViewController: UIViewController {
    var deleteRequestIndexPath: IndexPath? = nil
    @IBOutlet weak var tableView: UITableView!
    var Index: IndexPath? = nil
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
        
        
        Firestore.firestore().collection("helpRequests").whereField("CGEmail", isEqualTo: CGEmail!).whereField("status", isEqualTo: "new").addSnapshotListener { (querySnapshot, error) in
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
                let profilePhoto = data["VIProfilePhoto"] as? String ?? ""
                let lat = data["lat"] as? Double ?? 0
                let lng = data["long"] as? Double ?? 0
                let inddorLocation = data["inddorLocation"] as? String ?? ""



                
                
                return HelpRequest(CGEmail: CGEmail, CGName: CGName,CGPhoneNum: CGPhoneNum,VIEmail:VIEmail,VIName:VIName,VIPhoneNum:VIPhoneNum,VIProfilePhoto:profilePhoto,status:status,lat:lat,lng:lng,inddorLocation:inddorLocation)
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
    
// Layan
//    @IBAction func toMap(_ sender: Any) {
//        performSegue(withIdentifier: "goToMap", sender: self)
//
//    }
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
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "??????"
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
        if editingStyle == .delete {
            deleteRequestIndexPath = indexPath
            let requestsToDelete = HelpRequests[indexPath.row]
            confirmDelete(requestsToDelete: requestsToDelete)
        }
    }

   
    func confirmDelete(requestsToDelete:HelpRequest) {
        let alert = UIAlertController(title: "?????? ??????", message: "???? ?????? ?????????? ?????? ???????? ?????? ?????? ?????????? ??", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "??????", style: .destructive, handler: handleDeleteRequest)
        let CancelAction = UIAlertAction(title: "??????????", style: .cancel, handler: cancelDeleteRequest)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    func handleDeleteRequest(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteRequestIndexPath {
            
            tableView.beginUpdates()
            let VIEmail =   HelpRequests[indexPath.row].VIEmail
             let CGEmail =  HelpRequests[indexPath.row].CGEmail
            HelpRequests.remove(at: indexPath.row)
          
            Firestore.firestore().collection("helpRequests").document(VIEmail+"-"+CGEmail).updateData(["status" : "deleted"])
           
            // Note that indexPath is wrapped in an array:  [indexPath]
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            deleteRequestIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteRequest(alertAction: UIAlertAction!) {
        deleteRequestIndexPath = nil
        
        
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
        if let  url = HelpRequests[indexPath.row].VIProfilePhoto{
            let storageRef = Storage.storage().reference(forURL: url)
            storageRef.downloadURL(completion: { (url, error) in
                
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: (data! as NSData) as Data)
                
              
                cell.VIProfilePhoto.image = image
                
            })}
        cell.videoCallButton?.tag = indexPath.row
       cell.videoCallButton?.addTarget(self, action: #selector(videoCallButtonTapped), for: .touchUpInside)
       

   
        cell.helpRequestLabel?.text = "?????? " + HelpRequests[indexPath.row].VIName + " ???????????? ?????? ????????????"
        return cell
    }
    
    //Layan
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? mapViewController{
//            destination.VIname = HelpRequests[Index!.row].VIName
//            destination.VICurrentLocation = HelpRequests[Index!.row].inddorLocation
//            destination.lat = HelpRequests[Index!.row].lat
//            destination.lng = HelpRequests[Index!.row].lng
//
//
//        }
//    }
    
    
}

