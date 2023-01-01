//
//  FavoritesListViewController.swift
//  Dollani
//
//  Created by Nada  on 24/12/2022.
//

import UIKit
import Firebase

class FavoritesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @Published var users = [User]()
    var favPlaceList  = [String] ()
    var db = Firestore.firestore()
    var Index: IndexPath? = nil

    override func viewWillAppear(_ animated: Bool) {
        db.collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            if  error != nil {
                //                print(error.localizedDescription)}
            }
            else{
                favPlaceList = snapshot?.documents.first?.get("favPlace") as! [String]
                if ( favPlaceList.count == 0 ){
                    let alert = UIAlertController(title: "نعتذر", message:"لم تقم بإضافة اماكن الى المفضلة", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title:  "تم", style: .default, handler: { (_) -> Void in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
                        vc.modalPresentationStyle = .overFullScreen
                        present(vc, animated: true)
                    }))
                                    present(alert, animated: true, completion: nil)

              
                }
                fetchData()
                
            }
           
        }}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navBar.delegate = self
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
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Index = indexPath
    }

   
    @IBAction func forwardTapped(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "details")
//        vc.modalPresentationStyle = .overFullScreen
//        present(vc, animated: true)
        performSegue(withIdentifier: "Favdetails", sender: self)


    }

    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ){
            if let destination = segue.destination as? placeDetailsViewController{
                    destination.place = favPlaceList[Index!.row]
                    destination.index = Index!.row

            }
    }
}
