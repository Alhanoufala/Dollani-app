//
//  PathMapperViewControllerFav.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 05/07/1444 AH.
//

import UIKit
import SwiftUI
import Firebase

class PathMapperViewControllerFav: UIViewController,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var container: UIView!
    var place :Place!
    var source : CGPoint!
    var index = 0
    var Check = false

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
        
        
        if let navigate = segue.destination as? NavigationViewControllerFav{
            navigate.path     = pethMapperObj.mapPathVertices
            
            navigate.destinationPlace = place
            navigate.sourcePoint = source
            
        }
        
    }
    
    
    //MARK: - Navigation bar delegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
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
    
    @IBAction func removeFav(_ sender: Any) {
        if Check == true {
                 let alert = UIAlertController(title: nil, message:"تم الغاء التفضيل", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title:  "حسنًا", style: .default, handler: nil))
                                 present(alert, animated: true, completion: nil)
             }

        
        if Check == false
                 {
            Check = true
                     let db = Firestore.firestore()
            let alert = UIAlertController(title: nil, message:"هل تريد الغاء التفضيل ؟", preferredStyle: .alert)


                    let finishAction = UIAlertAction(title: "الغاء التفضيل", style: .destructive){_ in
                        Firestore.firestore().collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
                            if  error != nil {
                                print(error!.localizedDescription)
                            }
                            else{
                                favPlaceList = snapshot?.documents.first?.get("favPlace") as! [String]
                                

                                        favPlaceList.remove(at:index)
                             
                                db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (result, error) in
                                    if error == nil{
                                        for document in result!.documents{
                                            document.reference.updateData([
                                                "favPlace": favPlaceList
                                            ])
                                        }
                                    
                                
                            }
                            }
                                
                                let alert = UIAlertController(title: nil, message:"  تم الغاء التفضيل بنجاح", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title:  "حسنًا", style: .default, handler: nil))
                                                present(alert, animated: true, completion: nil)

                          
                            
                            }
                        
                        }
    //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //                    let vc = storyboard.instantiateViewController(identifier: "FavList")
    //                    vc.modalPresentationStyle = .overFullScreen
    //                    self.present(vc, animated: true)
                    }
                    alert.addAction(finishAction)
                    alert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
                    present(alert, animated: true, completion: nil)



                }
                 }
   
}
