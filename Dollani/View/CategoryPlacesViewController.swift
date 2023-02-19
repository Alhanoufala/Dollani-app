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
    var i : Int!

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
                self.i =    self.listOfCategory.firstIndex(where: {$0 == "اخرى"})!
                self.listOfCategory.remove(at: self.i)
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
        self.listOfCategorySearch = []
        for i in stride(from: 0, to: listOfCategory.count, by: 1) {
            for j in stride(from: 0, to: search.count, by: 1){
                if(listOfCategory[i] == search[j] ){
                    self.listOfCategorySearch.append(listOfCategory[i])
                }
            }
        }
       
    }

}
extension CategoryPlacesViewController: UISearchBarDelegate{
    public func searchBar(_ searchbar: UISearchBar ,  textDidChange searchText: String ){
        search = listOfCategory.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased() })
        if ( search.count == 0 ){
            let alert = UIAlertController(title: "نعتذر", message: " لا يوجد مكان بهذا الاسم ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "حسنًا", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
        }
        updateSearch()
        searching = true
        tableView.reloadData()
    }
    

}
