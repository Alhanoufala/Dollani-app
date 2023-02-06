//
//  FavoritesListViewController.swift
//  Dollani
//
//  Created by Nada  on 24/12/2022.
//

import UIKit
import Firebase
import EstimoteProximitySDK
import CoreLocation
class FavoritesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationBarDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @Published var users = [User]()
    var favPlaceList  = [Place] ()
    var favPlaceListString  = [String] ()
    var favPlaceListName  = [String] ()

    
    var search = [String]()
    var favPlaceListSearch  = [Place] ()
    var searching = false
    
    var source :CGPoint?
    var db = Firestore.firestore()
    var Index: IndexPath? = nil
    // 1. Add a property to hold the Proximity Observer
    var proximityObserver: ProximityObserver!
    private let manager = CLLocationManager()
    @IBOutlet weak var searchbar: UISearchBar!
    override func viewWillAppear(_ animated: Bool) {
        
        db.collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            if  error != nil {
                //                print(error.localizedDescription)}
            }
            else{
                favPlaceListString = snapshot?.documents.first?.get("favPlace") as! [String]
                if ( favPlaceListString.count == 0 ){
                    let alert = UIAlertController(title: "نعتذر", message:"لم تقم بإضافة اماكن الى المفضلة", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title:  "حسنًا", style: .default, handler: { (_) -> Void in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true)
                    }))
                                    present(alert, animated: true, completion: nil)

              
                }
                retrivePlaces()
                fetchData()
                
            }
           
        }

    }
    func retrivePlaces(){

        if(favPlaceListString.count < 10 && favPlaceListString.count != 0){
            Firestore.firestore().collection("places").whereField("name",in:favPlaceListString).order(by: "name").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                
                self.favPlaceList = documents.map { (queryDocumentSnapshot) -> Place in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let cat = data["category"] as? String ?? ""
                    let x = data["x"] as? Int ?? 0
                    let y = data["y"] as? Int ?? 0
                    self.favPlaceListName.append(name)
                    
                    return Place(name: name, cat: cat,x:x,y:y)
                    
                }
                
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()

        tableView.dataSource = self
        tableView.delegate = self
        searchbar.delegate = self
        navBar.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }
        let cloudCredentials = CloudCredentials(appID: "dollani-bi1",
                                                appToken: "b62b4121000e11265883334fe1a89e13")
        // 2. Create the Proximity Observer
        self.proximityObserver = ProximityObserver(
            credentials: cloudCredentials,
            onError: { error in
                print("proximity observer error: \(error)")
            })
        setTheSource()
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
                let fcmToken =  data["fcmToken"] as? String ?? ""
                return User(name: name, email: email,phoneNum: phoneNum, category: category,fcmToken: fcmToken, favPlace: favPlace)
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return search.count
        }else{
            return favPlaceList.count}
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favListCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        if searching{
            cell.textLabel?.text = search[indexPath.row]
        } else {
            cell.textLabel?.text = favPlaceList[indexPath.row].name }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Index = indexPath
        performSegue(withIdentifier: "ToMap", sender: self)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

         let deatil = segue.destination as! PathMapperViewControllerFav
        if favPlaceListSearch.count != 0 {
            deatil.place = favPlaceListSearch[Index!.row]
        }
          
            else{
                deatil.place =  favPlaceList[Index!.row]
                deatil.index = Index!.row

            }
         
        deatil.source = source ??  CGPoint(x: 207, y: 415)
            
            
        
    }
    func setTheSource(){
        let zone1 = ProximityZone(tag: "place 1", range: .near)
        let zone2 = ProximityZone(tag: "place 2", range: .near)
        let zone3 = ProximityZone(tag: "place 3", range: .near)
        let zone4 = ProximityZone(tag: "place 4", range: .near)
        
      
       
        // first zone
        zone1.onEnter = { context in
            self.source =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
         
            
            
        }
        
        //Second zone
        zone2.onEnter = { context in
            self.source =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
        
        }
        //Third zone
        zone3.onEnter = { context in
            
            self.source =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
        
        }
        //Fourth zone
        zone4.onEnter = { context in
            
            self.source =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
        
        }
        
      
        
        self.proximityObserver.startObserving([zone1,zone2,zone3,zone4])
       
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
    
    
 
    
    func updateSearch(){
        if(search.count < 10 && search.count != 0 ){
            Firestore.firestore().collection("places").whereField("name",in:search).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                
                self.favPlaceListSearch = documents.map { (queryDocumentSnapshot) -> Place in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let cat = data["category"] as? String ?? ""
                    let x = data["x"] as? Int ?? 0
                    let y = data["y"] as? Int ?? 0
                    
                    
                    return Place(name: name, cat: cat,x:x,y:y)
                    
                }
                
                
            }
        }
    }
        
    }
    
    

extension FavoritesListViewController: UISearchBarDelegate{
    public func searchBar(_ searchbar: UISearchBar ,  textDidChange searchText: String ){
        search = favPlaceListName.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased() })
       updateSearch()
        searching = true
        tableView.reloadData()
    }
    

}
