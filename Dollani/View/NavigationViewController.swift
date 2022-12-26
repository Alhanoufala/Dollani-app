//
//  NavigationViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 02/06/1444 AH.
//

import UIKit
import EstimoteProximitySDK

class NavigationViewController: UIViewController {
    
    // 1. Add a property to hold the Proximity Observer
       var proximityObserver: ProximityObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cloudCredentials = CloudCredentials(appID: "dollani-1us",
                                                  appToken: "7da1eb3f0c7caf075ba079e35e8e4da9")
        // 2. Create the Proximity Observer
               self.proximityObserver = ProximityObserver(
                   credentials: cloudCredentials,
                   onError: { error in
                       print("proximity observer error: \(error)")
               })
 
        let zone = ProximityZone(tag: "desks", range: .near)
        zone.onEnter = { context in
            let deskOwner = context.attachments["desk-owner"]
            print("Welcome to \(String(describing: deskOwner))'s desk")
        }
        zone.onExit = { _ in
            print("Bye bye, come again!")
        }
        
        self.proximityObserver.startObserving([zone])
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
