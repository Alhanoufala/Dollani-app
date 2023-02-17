//
//  profileHelpViewController.swift
//  Dollani
//
//  Created by Nada  on 11/02/2023.
//

import Foundation

import UIKit

class profileHelpViewController: UIViewController,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CG"){
            if let container = segue.destination as? CGcontainerViewController{
                container.index = 0
            }
        }
        if (segue.identifier == "VI"){
            
            if let container = segue.destination as? VIcontainerViewController{
                container.index = 0
            }
        }
        
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
}
