//
//  placesViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 05/06/1444 AH.
//

import UIKit
import Firebase
import EstimoteProximitySDK
import CoreLocation

class placesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,UINavigationBarDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    var search = [String]()
    @Published var placeName = [String]()
    @Published var PlaceListSearch = [Place]()

    var searching = false
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var category  = ""
    var Index: IndexPath? = nil
    @Published var PlaceList = [Place]()
    var source :CGPoint?

    var db = Firestore.firestore()
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
      
    }
    // 1. Add a property to hold the Proximity Observer
    var proximityObserver: ProximityObserver!
    private let manager = CLLocationManager()

    func fetchData() {
        
        Firestore.firestore().collection("places").whereField("category", isEqualTo: category).whereField("building", isEqualTo: "الحاسب").addSnapshotListener { (querySnapshot, error) in
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
                    self.placeName.append(name)
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
    func setTheSource(){
        let zone1 = ProximityZone(tag: "place 1", range: ProximityRange(desiredMeanTriggerDistance: 5.0)!)
        let zone2 = ProximityZone(tag: "place 2", range: ProximityRange(desiredMeanTriggerDistance: 5.0)!)
        let zone3 = ProximityZone(tag: "place 3", range: ProximityRange(desiredMeanTriggerDistance: 5.0)!)
        let zone4 = ProximityZone(tag: "place 4", range: ProximityRange(desiredMeanTriggerDistance: 5.0)!)
        
      
       
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
        // Do any additional setup after loading the view.
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return search.count
        }else{
            return placeName.count}
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        cell.textLabel?.textAlignment = .right
        
        if searching{
            cell.textLabel?.text = search[indexPath.row]
        }else{
            cell.textLabel?.text = placeName[indexPath.row]
        }
        
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

         let deatil = segue.destination as! PathMapperViewController
        if PlaceListSearch.count != 0 {
            deatil.place = PlaceListSearch[Index!.row]
        }
          
            else{
                deatil.place =  PlaceList[Index!.row]
            }
         
            deatil.source = source ??  CGPoint(x: 207, y: 415)
            
            
        
    }
    func updateSearch(){
        if(search.count < 10 && search.count != 0 ){
            Firestore.firestore().collection("places").whereField("name",in:search).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                
                self.PlaceListSearch = documents.map { (queryDocumentSnapshot) -> Place in
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
    
    
    
  
    


extension placesViewController: UISearchBarDelegate{
    public func searchBar(_ searchbar: UISearchBar ,  textDidChange searchText: String ){
        search = placeName.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased() })
        updateSearch()
        searching = true
        tableView.reloadData()
    }
    

}

