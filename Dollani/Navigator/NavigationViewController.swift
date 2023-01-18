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
    var path:[Vertex]!
    var visited = [Bool]()
    var destination = ""
    var destinationTag = ""
    var VIPhoneNum = ""
    var VIName = ""
    var VIProfilePhoto = ""
    var inddorLocation = ""
    var lat:Double!
    var long:Double!
    var timer = Timer()
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
    
    func setVisited(){
        for i in stride(from: 0, to: path.count, by: 1) {
            visited.append(false)
        }
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
    @objc
    func getDirectionsFromPath(){
        var dis :Double
        var feets: String
    
        for i in stride(from: 0, to: path.count, by: 1) {
         
         
          //same vertical hallway
            if((path[i].point != path.last?.point )&&(path[i].point.x == path[i+1].point.x) &&  (visited[i] == false )){
                dis =   DistanceFormula(from: path[i].point, to:path[i+1].point)
                feets = disToFeet(number: dis)
                //End of the hallway (left or  right)
                if (path[i].previousHallway?.end) != nil {
                    if(path[i].point == path[i].previousHallway?.end ){
                        if(path[i+1].point.x < path[i].previousHallway!.end.x ){
                            directionLabel.text?.append( "انعطف الى اليسار\n\n")
                           
                        }
                        else{
                            directionLabel.text?.append( "انعطف الى اليمين\n\n")
                        }
                    }
                }
             
                directionLabel.text?.append( " استمر في المشي خطوات\(feets) الى الأمام\n\n")
               
                
               visited[i] = true
            }
                //same horizontal  hallway
            else if((path[i].point != path.last?.point )&&(path[i].point.y == path[i+1].point.y) &&  (visited[i] == false )){
                dis =   DistanceFormula(from: path[i].point, to:path[i+1].point)
                feets = disToFeet(number: dis)
                //End of the hallway (left or  right)
                if (path[i].previousHallway?.end) != nil {
                    if(path[i].point == path[i].previousHallway?.end ){
                        if(path[i+1].point.x < path[i].previousHallway!.end.x ){
                            directionLabel.text?.append( "انعطف الى اليسار\n\n")
                          
                        }
                        else{
                            directionLabel.text?.append( "انعطف الى اليمين\n\n")
                            
                        }
                    }
                }
                directionLabel.text?.append( " استمر في المشي خطوات\(feets) الى الأمام\n\n")
              
              
                visited[i] = true
            }
            
               
           
            
            
            else if(path[i].point == path.last?.point){
                directionLabel.text?.append("لقد وصلت الى وجهتك")
                //Stop the timer
                timer.invalidate()
               
            }
            
            }
    }
        func DistanceFormula(from: CGPoint, to: CGPoint) -> CGFloat {
            let squaredDistance = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
            return sqrt(squaredDistance)
        }
    //from dis to feet
    func disToFeet(number: CGFloat) -> String {
        //let feetConversionFactor = CGFloat(1) / CGFloat(2) /// 1 pixel = half feet
        let feet = number * 3.2808
        let feetRounded = Int(feet) /// round to nearest integer
        return "\(feetRounded)"
    }

    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(getDirectionsFromPath), userInfo: nil, repeats: true)
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
            sender.sendPushNotification(to:CGUser.fcmToken!, title: "دلني", body: "قام احد جهات الاتصال بارسال طلب مساعدة ")
        }
        //alert
        let alert = UIAlertController(title: nil, message:"تم ارسال الطلب بنجاج", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "الغاء", style: .default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVisited()
        scheduledTimerWithTimeInterval()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }

        navBar.delegate = self
        farmeLabel.layer.borderWidth = 4
        farmeLabel.layer.borderColor =  UIColor(red: 43/255.0, green: 66/255.0, blue: 143/255.0, alpha: 255.0/255.0).cgColor
       
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
        
     
        movementDetected ()
        
     
           
       
    }
    
    
    func movementDetected (){
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
           
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
    

