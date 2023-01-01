//
//  VIPlacesDetailViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 06/06/1444 AH.
//

import UIKit
import Firebase


class VIPlacesDetailViewController: UIViewController,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var distance: UILabel!
    var favPlaceList  = [String] ()

    var place =  " "
    var dis = ""
    var cat = ""
    var index = 0
    var db = Firestore.firestore()

    @IBOutlet weak var DetailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        placeName.text = "\(place)"
        DetailLabel.layer.borderWidth = 4
        DetailLabel.layer.borderColor =  UIColor(red: 43/255.0, green: 66/255.0, blue: 143/255.0, alpha: 255.0/255.0).cgColor
        Firestore.firestore().collection("places").whereField("name",isEqualTo:place).getDocuments { [self] snapshot, error in
            if  error != nil {
                //                print(error.localizedDescription)}
            }
            else{
              cat = snapshot?.documents.first?.get("category") as! String
                
                dis = snapshot?.documents.first?.get("distance") as! String
                distance.text = "على بعد \(dis) متر "
                category.text = cat
            }
        }
                                           }
   
                                           
    @IBAction func backButtent(_ sender: Any) {
        performSegue(withIdentifier: "BackToPlaces", sender: self)
       /* let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "placesList")
       vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)*/

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let placesList = segue.destination as? placesViewController{
            placesList.category = cat
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
            if (favPlaceList.contains(place)) {
                let alert = UIAlertController(title: nil, message:"  الموقع مضاف للمفضلة مسبقًا", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:  "تم", style: .default, handler: nil))
                                present(alert, animated: true, completion: nil) }
            else{
            favPlaceList.append(place)}
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
    
    @IBAction func startNavigation(_ sender: Any) {
    }
    
}
