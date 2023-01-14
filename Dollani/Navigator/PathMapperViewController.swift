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
    var favPlaceList  = [String] ()
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
    let childView = UIHostingController(rootView: PathMapperContentView(place: place))
        addChild(childView)
        childView.view.frame = container.bounds
        container.addSubview(childView.view)
        // Do any additional setup after loading the view.
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
