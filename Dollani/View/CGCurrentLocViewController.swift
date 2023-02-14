//
//  CGCurrentLocViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 27/06/1444 AH.
//

import UIKit
import SwiftUI
import Firebase

class CGCurrentLocViewController: UIViewController,UINavigationBarDelegate {
    var place :Place!
    var source : CGPoint!
    var pethMapperObj :CGPathMapperContentView!
    var phoneNum:String!
    @Published  var hallways = [DirectionalHallway]()
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        getHallways()
        navBar.delegate = self
        // Do any additional setup after loading the view.
    }
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
            self.pethMapperObj = CGPathMapperContentView(place_: self.place,hallways_:self.hallways,source_:self.source )
            
            let childView = UIHostingController(rootView: self.pethMapperObj)
            self.addChild(childView)
            childView.view.frame = self.container.bounds
            self.container.addSubview(childView.view)
            
            
          
        }
    }
    
    
    @IBAction func videoCall(_ sender: Any) {
        //Perform the call
        
        if let url = URL(string: "facetime://" + phoneNum ){
            UIApplication.shared.open(url,options: [:],completionHandler: nil)
        }
    }
    

    @IBAction func backButten(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CGHelpRequests")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let container = segue.destination as? CGcontainerViewController{
            container.index = 1
        }
    }
}
