//
//  CategoryPlacesViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 01/06/1444 AH.
//

import UIKit
import Firebase

class CategoryPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var listOfCategory  = [String] ()
    var db = Firestore.firestore()

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
     
        // Do any additional setup after loading the view.
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
 
    
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func forwardButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "placesList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)

    }
    
   

}
