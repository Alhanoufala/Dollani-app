//
//  PathMapperViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 16/06/1444 AH.
//

import UIKit
import SwiftUI
import Firebase

class PathMapperViewController: UIViewController,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var container: UIView!
    var place :Place!
    @Published var PlaceList = [Place]()
    @Published  var classrooms = [Classroom]()
    var favPlaceList  = [String] ()
  var pethMapperObj :PathMapperContentView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        pethMapperObj = PathMapperContentView(place: place,classrooms:classrooms)
    let childView = UIHostingController(rootView: pethMapperObj)
        addChild(childView)
        childView.view.frame = container.bounds
        container.addSubview(childView.view)
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ){
            if let  places = segue.destination as? placesViewController{
                places.category     = place.cat
                
                
            }
        if let navigate = segue.destination as? NavigationViewController{
            navigate.path     = pethMapperObj.mapPathVertices
            
            
        }
        
    }
    
    
    //MARK: - Navigation bar delegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        print(location )
    }
    func getPlaces(){
        Firestore.firestore().collection("places").whereField("building", isEqualTo: "الحاسب").addSnapshotListener { (querySnapshot, error) in
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
            
            self.classrooms = self.PlaceList.map { (place) -> Classroom in
                
                let name = place.name
                let entrancePoint  = CGPoint(x: place.x,y: place.y)
                
                
                return Classroom(name: name,entrancePoint:entrancePoint )
                
            }
            
        }
    }
    @IBAction func addToFav(_ sender: Any) {
        let db = Firestore.firestore()
        db.collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
                favPlaceList = snapshot?.documents.first?.get("favPlace") as! [String]
            }
            if (favPlaceList.contains(place.name)) {
                let alert = UIAlertController(title: nil, message:"  الموقع مضاف للمفضلة مسبقًا", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:  "تم", style: .default, handler: nil))
                                present(alert, animated: true, completion: nil) }
            else{
                favPlaceList.append(place.name)}
            db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (result, error) in
                if error == nil{
                    for document in result!.documents{
                        document.reference.updateData([
                                       "favPlace": favPlaceList
                                   ])
                    }
                }
            }
                let alert = UIAlertController(title: nil, message:"  تم إضافة الموقع للمفضلة بنجاح", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:  "تم", style: .default, handler: nil))
                                present(alert, animated: true, completion: nil)

          
            
 
            
        }
        
    }

}
