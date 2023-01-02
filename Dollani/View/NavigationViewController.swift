//
//  NavigationViewController.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 02/06/1444 AH.
//

import UIKit
import EstimoteProximitySDK
import CoreMotion
import AudioToolbox
import AVFoundation
import CoreLocation

class NavigationViewController: UIViewController {
    
    // Provides to create an instance of the CMMotionActivityManager.
    private let activityManager = CMMotionActivityManager()
    /// Provides to create an instance of the CMPedometer.
private let pedometer = CMPedometer()
    
    let motionManager = CMMotionManager()
    // 1. Add a property to hold the Proximity Observer
       var proximityObserver: ProximityObserver!
    private let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManagerDidChangeAuthorization(manager)
        let cloudCredentials = CloudCredentials(appID: "dollani-bi1",
                                                  appToken: "b62b4121000e11265883334fe1a89e13")
        // 2. Create the Proximity Observer
               self.proximityObserver = ProximityObserver(
                   credentials: cloudCredentials,
                   onError: { error in
                       print("proximity observer error: \(error)")
               })
 
        let zone = ProximityZone(tag: "place", range: .far)
        zone.onEnter = { context in
            
            let placeName = context.attachments["place-name"]
          
            print("Welcome to \(String(describing: placeName))")
        }
        zone.onExit = { _ in
            print("Bye bye, come again!")
        }
        
        self.proximityObserver.startObserving([zone])
        
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
           guard let activity = activity else { return }
           DispatchQueue.main.async {
               if activity.stationary {
                   print("Stationary")
             
               } else if activity.walking {
                    // With vibration
                  
                    AudioServicesPlaySystemSound(1352)
                    print("Walking")
                } else if activity.running {
                   AudioServicesPlaySystemSound(1352)
                print("Running")
                } else if activity.automotive {
                   print("Automotive")
               }
            }
        }
       // if CMPedometer.isStepCountingAvailable() {
           // pedometer.startUpdates(from: Date()) { pedometerData, error in
              //  guard let pedometerData = pedometerData, error == nil else { return }
                
//DispatchQueue.main.async {
                    //print(pedometerData.numberOfSteps.intValue)
               // }
           // }
      //  }
        
       
        
       // motionManager.deviceMotionUpdateInterval = 1
       // motionManager.showsDeviceMovementDisplay = true
      
       // motionManager.startDeviceMotionUpdates( to:OperationQueue(), withHandler: handleUpdate)
   
        }
    //func handleUpdate(data: CMDeviceMotion!, error: Error!) {
           // if data != nil {
               
             //   let field = data.magneticField.field
               
               // print("\(field.x), \(field.y), \(field.z)")
            //}
    //}
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
           // enableLocationFeatures()
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
           // disableLocationFeatures()
            break
            
        case .notDetermined:        // Authorization not determined yet.
           manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }

   
   
}
