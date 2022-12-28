//
//  placeDetailsViewController.swift
//  Dollani
//
//  Created by Nada  on 25/12/2022.
//
//

import Foundation
import UIKit
import Firebase

class placeDetailsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @Published var users = [User]()
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.dataSource = self
        details.delegate = self
        fetchData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = "test"
        cell.layer.borderWidth = 7
        cell.layer.borderColor = UIColor.blue.cgColor
       
        return cell
    }
    @IBAction func removeFav(_ sender: Any) {
        
    }
    @IBAction func startNavigation(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
   
    @IBOutlet weak var details: UITableView!
    
    func fetchData(){
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
            self.details.reloadData()
        }

        }

    
    
}

