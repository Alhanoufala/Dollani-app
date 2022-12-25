//
//  placeDetailsViewController.swift
//  Dollani
//
//  Created by Nada  on 25/12/2022.
//

import Foundation
import UIKit

class placeDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FavList")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
   
    
}
