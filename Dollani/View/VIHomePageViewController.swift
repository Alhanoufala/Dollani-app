//
//  VIHomePageViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 20/05/1444 AH.
//

import UIKit
import Firebase

class VIHomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func navigationTapped(_ sender: Any) {
      //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(identifier: "navigation")
       // vc.modalPresentationStyle = .overFullScreen
        //present(vc, animated: true)
    }
    @IBAction func askForHelpTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "askForHelp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}
