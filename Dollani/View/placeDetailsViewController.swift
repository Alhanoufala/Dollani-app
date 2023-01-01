//
//  placeDetailsViewController.swift
//  Dollani
//
//  Created by Nada  on 25/12/2022.
//
//

import UIKit
import Firebase
import UIKit
import Firebase

class placeDetailsViewController: UIViewController,UINavigationBarDelegate {
    @Published var users = [User]()
    var db = Firestore.firestore()
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var placeName: UILabel!
    var place =  " "
    var index = 0
    var favPlaceList  = [String] ()
    var dis = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        placeName.text = "\(place)"
        placeLabel.layer.borderWidth = 4
        placeLabel.layer.borderColor =  UIColor(red: 43/255.0, green: 66/255.0, blue: 143/255.0, alpha: 255.0/255.0).cgColor
        let db = Firestore.firestore()
        db.collection("places").whereField("name",isEqualTo: place).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
                categoryLabel.text = snapshot?.documents.first?.get("category") as! String
                dis = snapshot?.documents.first?.get("distance") as! String
                distance.text = "على بعد \(dis) متر"

            }
        }
    }

    @IBAction func removeFav(_ sender: Any) {
        let db = Firestore.firestore()
        db.collection("users").whereField("email",isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
                favPlaceList = snapshot?.documents.first?.get("favPlace") as! [String]
            }
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
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @IBAction func startNavigation(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}
