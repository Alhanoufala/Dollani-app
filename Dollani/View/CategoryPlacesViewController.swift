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
    var listOfCategorySearch  = [String] ()
    var search = [String]()
    
    var searching = false
    
    var db = Firestore.firestore()
    var Index: IndexPath? = nil

    @IBOutlet weak var searchbar: UISearchBar!
    
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
        searchbar.delegate = self
        navBar.delegate = self
        // Do any additional setup after loading the view.
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
           return search.count
        } else{
            return listOfCategory.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        if searching {
            cell.textLabel?.text = search[indexPath.row]
        }
        else{
            cell.textLabel?.text = listOfCategory[indexPath.row]
        }
        
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
         let placesList = segue.destination as! placesViewController
        if listOfCategorySearch.count != 0 {
            placesList.category = listOfCategorySearch[Index!.row]
        }
        else{
            placesList.category = listOfCategory[Index!.row]
        }
        
    }
    
    func updateSearch(){
        if(search.count < 10 && search.count != 0 ){
        Firestore.firestore().collection("categories").getDocuments { snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
        
            else{
                self.listOfCategorySearch = snapshot?.documents.first?.get("categoriesP") as? [String] ?? []
               
                
            }
        }

        }
    }

}
extension CategoryPlacesViewController: UISearchBarDelegate{
    public func searchBar(_ searchbar: UISearchBar ,  textDidChange searchText: String ){
        search = listOfCategory.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased() })
        updateSearch()
        searching = true
        tableView.reloadData()
    }
    

}
