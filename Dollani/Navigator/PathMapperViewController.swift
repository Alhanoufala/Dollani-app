//
//  PathMapperViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 16/06/1444 AH.
//

import UIKit
import SwiftUI

class PathMapperViewController: UIViewController,UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
let childView = UIHostingController(rootView: PathMapperContentView())
        addChild(childView)
        childView.view.frame = container.bounds
        container.addSubview(childView.view)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    //MARK: - Navigation bar delegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }

}
