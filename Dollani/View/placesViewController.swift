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
        let zone1 = ProximityZone(tag: "place", range: .near)
        let zone2 = ProximityZone(tag: "place", range: .near)
        let zone3 = ProximityZone(tag: "place", range: .near)
        let zone4 = ProximityZone(tag: "place", range: .near)
        
      
       
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
            deatil.source = source ??  CGPoint(x: 207, y: 415)
            
            
        }
    }
    
    
   
    
}
extension UIViewController: UISearchBarDelegate{
    public func searchBar(_ searchbar: UISearchBar ,  textDidChange searchText: String ){
        
    }
}
