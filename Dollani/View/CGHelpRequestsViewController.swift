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
    var source = [CGPoint]()
    var Index: IndexPath? = nil
    @Published var HelpRequests = [HelpRequest]()
    @Published var PlaceList = [Place]()
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        getPlace()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    func getPlace(){
        let user = Auth.auth().currentUser
        let CGEmail = user?.email


        Firestore.firestore().collection("helpRequests").whereField("CGEmail", isEqualTo: CGEmail!).whereField("status", isEqualTo: "new").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.PlaceList = documents.map { (queryDocumentSnapshot) -> Place in
                let data = queryDocumentSnapshot.data()
                let x = data["destinationX"] as? Int ?? 0
                let y = data["destinationY"] as? Int ?? 0
                let destinationName = data["destinationName"] as? String ?? ""
                let destinationCat = data["destinationCat"] as? String ?? ""



             return Place(name: destinationName, cat: destinationCat, x: x, y: y)
            }
            self.tableView.reloadData()
        }
          
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
                let destinationName = data["destinationName"] as? String ?? ""
                                let destinationCat = data["destinationCat"] as? String ?? ""
                                let destinationX = data["destinationX"] as? Int ?? 0
                                let destinationY = data["destinationY"] as? Int ?? 0
                let sourcePoint =  CGPoint(x:Int(exactly: data["xStart"]  as! Int)! , y:    Int(exactly: data["yStart"] as! Int)!)

                 
                self.source.append(sourcePoint)
                   
               
            
                return HelpRequest(CGEmail: CGEmail, CGName: CGName,CGPhoneNum: CGPhoneNum,VIEmail:VIEmail,VIName:VIName,VIPhoneNum:VIPhoneNum,VIProfilePhoto:profilePhoto,status:status,sourcePoint:sourcePoint,destinationName:destinationName,destinationCat:destinationCat,destinationX:destinationX,destinationY:destinationY)
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
        return "حذف"
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
        let alert = UIAlertController(title: "حذف طلب", message: "هل أنت متأكد أنك تريد حذف هذا الطلب ؟", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "حذف", style: .destructive, handler: handleDeleteRequest)
        let CancelAction = UIAlertAction(title: "الغاء", style: .cancel, handler: cancelDeleteRequest)
        
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
       

   
        cell.helpRequestLabel?.text = "قام " + HelpRequests[indexPath.row].VIName + " بارسال طلب مساعدة"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

         let deatil = segue.destination as! CGCurrentLocViewController
        if PlaceList.count != 0 {
            deatil.place =  PlaceList[Index!.row]
            
            
            deatil.source = source[Index!.row]}
        else {
            print("error")
        }
            
            
        
    }
    
}

