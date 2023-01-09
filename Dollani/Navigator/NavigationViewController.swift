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
import Firebase

class NavigationViewController: UIViewController ,UINavigationBarDelegate,CLLocationManagerDelegate{
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var farmeLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    var destination = ""
    var destinationTag = ""
    var VIPhoneNum = ""
    var VIName = ""
    var VIProfilePhoto = ""
    var inddorLocation = ""
    var lat:Double!
    var long:Double!
    @Published var CGUsers = [User]()
    var CGEmailList = [String] ()
    // Provides to create an instance of the CMMotionActivityManager.
    private let activityManager = CMMotionActivityManager()
    /// Provides to create an instance of the CMPedometer.
    private let pedometer = CMPedometer()
    
    let motionManager = CMMotionManager()
    // 1. Add a property to hold the Proximity Observer
    var proximityObserver: ProximityObserver!
    private let manager = CLLocationManager()
    func checkDestination(){
        print(destination)
        if(destination == "25G قاعة" ){
            destinationTag = "room25"}
        else if(destination == "G50 قاعة"){
            destinationTag = "room50"}
    }
    
    func getCGEmails() {
        let user = Auth.auth().currentUser
        let VIEmail = user?.email
        
        //get the CG emails
        Firestore.firestore().collection("users").whereField("email",isEqualTo:VIEmail!).getDocuments { [self] snapshot, error in
            if  error != nil {
                print(error!.localizedDescription)
            }
            else{
                CGEmailList = snapshot?.documents.first?.get("CGEmail") as! [String]
                VIPhoneNum = snapshot?.documents.first?.get("phoneNum") as! String
                VIName = snapshot?.documents.first?.get("name") as! String
                VIProfilePhoto = snapshot?.documents.first?.get("profilePhoto") as! String
                fetchData()
                
                
                
                
            }
            
            
        }
    }
    
    func fetchData() {
    
        if(CGEmailList.count != 0){
            Firestore.firestore().collection("users").whereField("email", in: CGEmailList).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.CGUsers = documents.map { (queryDocumentSnapshot) -> User in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let phoneNum = data["phoneNum"] as? String ?? ""
                    let category = data["category"] as? String ?? ""
                    let fcmToken =  data["fcmToken"] as? String ?? ""
                    
                    return User(name: name, email: email,phoneNum: phoneNum,category:category,fcmToken: fcmToken)
                }
                
            }
        }
    }
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "places")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        //alert
        let alert = UIAlertController(title: nil, message:"هل تريد انهاء الطريق ؟", preferredStyle: .alert)
      
     
        let finishAction = UIAlertAction(title: "انهاء الطريق", style: .destructive){_ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "VIcontainer")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)}
        alert.addAction(finishAction)
        alert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func askForHelpTapped(_ sender: Any) {
        let sender = PushNotificationSender()
       
       
        for CGUser in CGUsers {
            Firestore.firestore().collection("helpRequests").document((Auth.auth().currentUser?.email)!+"-"+CGUser.email).setData(["CGName" : CGUser.name,"CGEmail":CGUser.email,"CGPhoneNum":CGUser.phoneNum,"VIEmail":(Auth.auth().currentUser?.email)!,"VIName":VIName,"VIPhoneNum":VIPhoneNum,"status":"new","VIProfilePhoto":VIProfilePhoto,"inddorLocation":inddorLocation,"lat":lat,"long":long])
            sender.sendPushNotification(to:CGUser.fcmToken!, title: "طلب مساعدة جديد ", body: "قام احد جهات الاتصال بارسال طلب مساعدة ")
        }
        //alert
        let alert = UIAlertController(title: nil, message:"تم ارسال الطلب بنجاج", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }

        navBar.delegate = self
        farmeLabel.layer.borderWidth = 4
        farmeLabel.layer.borderColor =  UIColor(red: 43/255.0, green: 66/255.0, blue: 143/255.0, alpha: 255.0/255.0).cgColor
        checkDestination()
      //  locationManagerDidChangeAuthorization(manager)
        getCGEmails()
       
        let cloudCredentials = CloudCredentials(appID: "dollani-bi1",
                                                appToken: "b62b4121000e11265883334fe1a89e13")
        // 2. Create the Proximity Observer
        self.proximityObserver = ProximityObserver(
            credentials: cloudCredentials,
            onError: { error in
                print("proximity observer error: \(error)")
            })
        navigateToDestination()
     
      //  movementDetected ()
        
     
           
       
    }
    func navigateToDestination(){
        let zone = ProximityZone(tag: "room25", range: .near)
        let zoneTag = zone.tag
        let zone2 = ProximityZone(tag: "room50", range: .near)
        let zoneTag2 = zone2.tag
        print(zoneTag)
        print(zoneTag2)
        // first zone
        zone.onEnter = { context in
            if(zoneTag == self.destinationTag ){
             
                    self.directionLabel.text = "لقد وصلت الى وجهتك"
                
                AudioServicesPlaySystemSound(1307)
            }
           
            
            else{
                self.inddorLocation = context.attachments["place-name"] as? String ?? ""
           
                    self.directionLabel.text = "امشي الى الامام ٨ متر"
                
            }
            
        }
        zone.onExit = {context in
            self.directionLabel.text = ""
        
        }
        // second zone
        zone2.onEnter = { context in
            if(zoneTag2 == self.destinationTag ){
            
                    self.directionLabel.text = "لقد وصلت الى وجهتك"
                
                AudioServicesPlaySystemSound(1307)
            }
           
            
            else{
                self.inddorLocation = context.attachments["place-name"] as? String ?? ""
                
                    self.directionLabel.text = "امشي الى الامام ٨ متر"
                
            }
        }
        zone2.onExit = {context in
            self.directionLabel.text = ""
        
        }
        
      
        
        self.proximityObserver.startObserving([zone,zone2])
       
    }
    func movementDetected (){
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
        
    }
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
      //Get the latitude and the longitude
      lat =   userLocation.coordinate.latitude
      long = userLocation.coordinate.longitude

       
            }
 

    
    
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
    //MARK: - Navigation bar delegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    
    
}
    

