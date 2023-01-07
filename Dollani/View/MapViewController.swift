//
//  MapViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 13/06/1444 AH.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func BackButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CGHelpRequests")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
}
