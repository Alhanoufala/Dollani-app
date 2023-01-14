//
//  CategoryPlacesViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 01/06/1444 AH.
//

import UIKit
import Firebase

class CategoryPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationBarDelegate {
    var listOfCategory  = [String] ()
    var db = Firestore.firestore()
    var Index: IndexPath? = nil

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
       
    }
    
    func fetchData(){
        
      
        Firestore.firestore().collection("categories").getDocuments { snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
        
            else{
                print(self.listOfCategory.count)
                self.listOfCategory = snapshot?.documents.first?.get("categoriesP") as? [String] ?? []
                self.tableView.reloadData()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navBar.delegate = self
        // Do any additional setup after loading the view.
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = listOfCategory[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Index = indexPath
        performSegue(withIdentifier: "goToListOfPlaces", sender: self)

    }
    
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let placesList = segue.destination as? placesViewController{
            placesList.category = listOfCategory[Index!.row]
        }
    }
    
   

}
