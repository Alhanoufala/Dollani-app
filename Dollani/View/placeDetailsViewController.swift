//
//  placeDetailsViewController.swift
//  Dollani
//
//  Created by Nada  on 25/12/2022.
//
//

import Foundation
import UIKit
import Firebase

class placeDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
 
    @IBAction func removeFav(_ sender: Any) {
        
    }
    @IBAction func startNavigation(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
   
//
//    func fetchData(){
//        let user = Auth.auth().currentUser
//        if user != nil {
//
//            Firestore.firestore().collection("places").whereField("name",isEqualTo:"23G").getDocuments { snapshot, error in
//
//                if  error != nil {
//                    // ERROR
//                }
//                else {
//                    if(snapshot?.count != 0){
//
//                        let collegeName = snapshot?.documents.first?.get("collage ") as! String
//                        print(collegeName)
//
//                        //Set textView
//                        self.placeDetails.text = collegeName
//                        self.placeDetails.layer.borderColor = UIColor.blue.cgColor
//                        self.placeDetails.layer.borderWidth = 7
//
//                    }
//                }
//            }
//
//        }
//
//    }
    
}

