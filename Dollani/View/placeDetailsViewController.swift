//
//  placeDetailsViewController.swift
//  Dollani
//
//  Created by Nada  on 25/12/2022.
//
//

import UIKit
import Firebase

class placeDetailsViewController: UIViewController,UINavigationBarDelegate {
    @Published var users = [User]()
    var db = Firestore.firestore()
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var placeLabel: UILabel!
    var place =  " "
    var index = 0
    var favPlaceList  = [String] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        placeLabel.text = "\(place)"
        placeLabel.layer.borderWidth = 7
        placeLabel.layer.borderColor =  UIColor(red: 43/255.0, green: 66/255.0, blue: 143/255.0, alpha: 255.0/255.0).cgColor
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath)
//        cell.textLabel?.textAlignment = .center
//        cell.textLabel?.text = "test"
//        cell.layer.borderWidth = 7
//        cell.layer.borderColor = UIColor.blue.cgColor
//
//        return cell
//    }
    @IBAction func removeFav(_ sender: Any) {
        let db = Firestore.firestore()
        db.collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
                favPlaceList = snapshot?.documents.first?.get("favPlace") as! [String]
            }
//            favPlaceList.append(place)
            favPlaceList.remove(at:index)
            db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (result, error) in
                if error == nil{
                    for document in result!.documents{
                        document.reference.updateData([
                                       "favPlace": favPlaceList
                                   ])
                    }
                }
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "FavList")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        }
    }
        
    @IBAction func startNavigation(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
   
    @IBOutlet weak var details: UITableView!
//
//    func fetchData(){
//        let owner = Auth.auth().currentUser?.email
//        db.collection("users").whereField("email", isEqualTo: owner!).addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents
//            else {
//                print("No documents")
//                return
//            }
//
//            self.users = documents.map { (queryDocumentSnapshot) -> User in
//                let data = queryDocumentSnapshot.data()
//                let name = data["name"] as? String ?? ""
//                let email = data["email"] as? String ?? ""
//                let phoneNum = data["phoneNum"] as? String ?? ""
//                let category = data["category"] as? String ?? ""
//                let favPlace = data["favPlace"] as? [String] ?? []
//
//                return User(name: name, email: email,phoneNum: phoneNum, category: category, favPlace: favPlace)
//            }
//            self.details.reloadData()
//        }
//
//        }
//
//
    
}

