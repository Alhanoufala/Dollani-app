//
//  profileHelpViewController.swift
//  Dollani
//
//  Created by Nada  on 11/02/2023.
//

import Foundation

import UIKit

class profileHelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func CGback(_ sender: Any) {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "CGcontainer")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
    }
    @IBAction func Viback(_ sender: Any) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
    }
}
