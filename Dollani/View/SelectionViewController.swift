//
//  SelectionViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 16/05/1444 AH.
//

import UIKit

class SelctionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SignUp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}
