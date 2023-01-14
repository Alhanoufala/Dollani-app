//
//  placesViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 05/06/1444 AH.
//

import UIKit
import Firebase

class placesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,UINavigationBarDelegate{
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    var category  = ""
    var Index: IndexPath? = nil
    @Published var PlaceList = [Place]()

    var db = Firestore.firestore()
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
      
    }

    func fetchData() {
        
            Firestore.firestore().collection("places").whereField("category", isEqualTo: category).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.PlaceList = documents.map { (queryDocumentSnapshot) -> Place in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let cat = data["category"] as? String ?? ""
                    let x = data["x"] as? Int ?? 0
                    let y = data["y"] as? Int ?? 0
            
                    return Place(name: name, cat: cat,x:x,y:y)
                
                }
                self.tableView.reloadData()
            }
        tableView.reloadData()
        
       
        
    }
     override func viewDidLoad() {
        super.viewDidLoad()
         tableView.delegate = self
         tableView.dataSource = self
         navBar.delegate = self
         
     }
        // Do any additional setup after loading the view.
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Index = indexPath
        performSegue(withIdentifier: "goToDetails", sender: self)

    }

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let deatil = segue.destination as? PathMapperViewController {
            deatil.place =  PlaceList[Index!.row]
            
            
        }
    }
    
    

    
}
