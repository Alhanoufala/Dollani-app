//
//  FavoritesListViewController.swift
//  Dollani
//
//  Created by Nada  on 24/12/2022.
//

import UIKit
import Firebase

class FavoritesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    @Published var users = [User]()
    var favPlaceList  = [String] ()
    var db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
                 favPlaceList = snapshot?.documents.first?.get("favPlace") as! [String]
                fetchData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func fetchData() {
        let owner = Auth.auth().currentUser?.email
    
        db.collection("users").whereField("email", isEqualTo: owner!).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents
            else {
                print("No documents")
                return
            }

            self.users = documents.map { (queryDocumentSnapshot) -> User in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let phoneNum = data["phoneNum"] as? String ?? ""
                let category = data["category"] as? String ?? ""
                let favPlace = data["favPlace"] as? [String] ?? []
              
                return User(name: name, email: email,phoneNum: phoneNum, category: category, favPlace: favPlace)
            }
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favPlaceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favListCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = favPlaceList[indexPath.row]
        return cell
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
  
}
