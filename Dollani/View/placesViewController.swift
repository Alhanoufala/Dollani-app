//
//  placesViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 05/06/1444 AH.
//

import UIKit
import Firebase

class placesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var nameP  = ""
    @Published var PlaceList = [Place]()

    var db = Firestore.firestore()
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
       
    }

    func fetchData() {
                
        Firestore.firestore().collection("places").whereField("category", isEqualTo: "قاعات دراسية").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.PlaceList = documents.map { (queryDocumentSnapshot) -> Place in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let cat = data["category"] as? String ?? ""
                
                
                return Place(name: name, cat: cat)
            }
            self.tableView.reloadData()
        }
        
    }
     override func viewDidLoad() {
        super.viewDidLoad()
         tableView.delegate = self
         tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaceList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = PlaceList[indexPath.row].name
        return cell
        
    }
    
    @IBAction func backButten(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "places")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    

}
