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
    var source : CGPoint!
   
    @Published  var hallways = [DirectionalHallway]()
    var favPlaceList  = [String] ()
  var pethMapperObj :PathMapperContentView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        getHallways()
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ){
            if let  places = segue.destination as? placesViewController{
                places.category     = place.cat
                
                
            }
        if let navigate = segue.destination as? NavigationViewController{
            navigate.path     = pethMapperObj.mapPathVertices
            
            navigate.destinationPlace = place
            
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
    func getHallways(){
        Firestore.firestore().collection("hallways").whereField("building", isEqualTo: "الحاسب").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.hallways = documents.map { (queryDocumentSnapshot) -> DirectionalHallway in
                let data = queryDocumentSnapshot.data()
                let start =  CGPoint(x: data["xStart"]as! Int,y: data["yStart"]as! Int)
                let end = CGPoint(x: data["xEnd"]as! Int,y: data["yEnd"]as! Int)
               
                
                return DirectionalHallway(start: start, end: end)
                
            }
            self.pethMapperObj = PathMapperContentView(place_: self.place,hallways_:self.hallways,source_:self.source )
            
            let childView = UIHostingController(rootView: self.pethMapperObj)
            self.addChild(childView)
            childView.view.frame = self.container.bounds
            self.container.addSubview(childView.view)
            
            
          
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
