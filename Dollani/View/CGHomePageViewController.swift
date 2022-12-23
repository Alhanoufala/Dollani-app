//
//  CGHomePageViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 28/05/1444 AH.
//

import Foundation
import UIKit
import Firebase

class CGHomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
   
    
    @IBAction func contactTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "contact")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
}
