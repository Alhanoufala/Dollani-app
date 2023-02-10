//
//  NavigationViewControllerFav.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 05/07/1444 AH.
//

import UIKit
import EstimoteProximitySDK
import CoreMotion
import AudioToolbox
import AVFoundation
import CoreLocation
import Firebase
import CoreNFC

class NavigationViewControllerFav: UIViewController ,UINavigationBarDelegate,CLLocationManagerDelegate , NFCNDEFReaderSessionDelegate {
    
    @IBOutlet weak var NFCmsg: UIButton!
    
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var farmeLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    var path:[Vertex]!
    var visited = [Bool]()
    var destinationPlace:Place!
    var sourcePoint:CGPoint!
    var VIPhoneNum = ""
    var VIName = ""
    var VIProfilePhoto = ""
   
    @Published var CGUsers = [User]()
    var CGEmailList = [String] ()
    
    // 1. Add a property to hold the Proximity Observer
    var proximityObserver: ProximityObserver!
    private let manager = CLLocationManager()
    
    func setVisited(){
        for _ in stride(from: 0, to: path.count, by: 1) {
            visited.append(false)
        }
    }
    func getIndex() ->Int{
        for i in stride(from: 0, to: path.count, by: 1) {
            if(   visited[i] == false){
                return i
            }
           
        }
        return 0
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
 
    func   getDirectionsFromPath(){
        var dis :Double
        var feets: String
        var arabicSteps: String
        var str = ""
       
         
        let i = getIndex()
          //same vertical hallway
            if((path[i].point != path.last?.point )&&(path[i].point.x == path[i+1].point.x) &&  (visited[i] == false )){
                dis =   DistanceFormula(from: path[i].point, to:path[i+1].point)
                feets = disToFeet(number: dis)
                arabicSteps = stepsToArabic(feets: feets)
                //End of the hallway (left or  right)
                if (path[i].previousHallway?.end) != nil {
                    if(path[i].point == path[i].previousHallway?.end ){
                        if(path[i+1].point.x < path[i].previousHallway!.end.x ){
                          
                           str =  "  انعطف الى اليسار ثم\n\n"
                        }
                        else{
                        
                           str = "انعطف الى اليمين ثم\n\n"
                        }
                    }
                }
               
                visited[i] = true
                self.directionLabel.text = str + " استمر في المشي الى الأمام\n\n"
            return
             
              
            }
                //same horizontal  hallway
            else if((path[i].point != path.last?.point )&&(path[i].point.y == path[i+1].point.y) &&  (visited[i] == false )){
                dis =   DistanceFormula(from: path[i].point, to:path[i+1].point)
                feets = disToFeet(number: dis)
                arabicSteps = stepsToArabic(feets: feets)
                //End of the hallway (left or  right)
                if (path[i].previousHallway?.end) != nil {
                    if(path[i].point == path[i].previousHallway?.end ){
                        if(path[i+1].point.x < path[i].previousHallway!.end.x ){
                           
                           str =  "انعطف الى اليسار ثم\n\n"
                           
                          
                        }
                        else{
                       
                             str = "انعطف الى اليمين ثم\n\n"
                          
                          
                            
                        }
                    }
                }
              
                visited[i] = true
                self.directionLabel.text = str + " استمر في المشي الى الأمام\n\n"
              
                return
            }
            
               
           
            else if((path[i].point == path.last?.point) &&  (visited[i] == false)){
                visited[i] = true
                              
                self.directionLabel.text = "لقد وصلت الى وجهتك"
               
                return
              
            }
            
           
            
            
          
        return
    }
        func DistanceFormula(from: CGPoint, to: CGPoint) -> CGFloat {
            let squaredDistance = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
            return sqrt(squaredDistance)
        }
    
    //from dis to feet
    
    func disToFeet(number: CGFloat) -> String {
        //let feetConversionFactor = CGFloat(1) / CGFloat(2) /// 1 pixel = half feet
        let feet = number / 4
        let feetRounded = Int(feet) /// round to nearest integer
        return "\(feetRounded)"
    }
    
    func stepsToArabic(feets: String) -> String{
        var steps = ""
        for ch in feets {
            switch ch{
            case "0":
                steps = steps + "٠"
            case "1":
                steps = steps + "١"
            case "2":
                steps = steps + "٢"
            case "3":
                steps = steps + "٣"
            case "4":
                steps = steps + "٤"
            case "5":
                steps = steps + "٥"
            case "6":
                steps = steps + "٦"
            case "7":
                steps = steps + "٧"
            case "8":
                steps = steps + "٨"
            case "9":
                steps = steps + "٩"
            default:
                steps = steps + ""
            }
        }
        return "\(steps)"
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
            Firestore.firestore().collection("helpRequests").document((Auth.auth().currentUser?.email)!+"-"+CGUser.email).setData(["CGName" : CGUser.name,"CGEmail":CGUser.email,"CGPhoneNum":CGUser.phoneNum,"VIEmail":(Auth.auth().currentUser?.email)!,"VIName":VIName,"VIPhoneNum":VIPhoneNum,"status":"new","VIProfilePhoto":VIProfilePhoto,"destinationName":destinationPlace.name,"destinationCat":destinationPlace.cat,"destinationX":destinationPlace.x,"destinationY":destinationPlace.y,"xStart":sourcePoint.x,"yStart":sourcePoint.y])
            sender.sendPushNotification(to:CGUser.fcmToken!, title: "دلني", body: "قام احد جهات الاتصال بارسال طلب مساعدة ")
        }
        //alert
        let alert = UIAlertController(title: nil, message:"تم ارسال الطلب بنجاح", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "حسنًا", style: .default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        //alert
        let alert = UIAlertController(title: "تعليمات", message:"سوف يهتز الجهاز عند ظهور الاتجاهات", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "حسنا", style: .default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVisited()
        getCGEmails()
        directionLabel.text = "أقترب من إحدى أجهزة ارسال البلوتوث لبدء التنقل "
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }

        navBar.delegate = self
        farmeLabel.layer.borderWidth = 4
        farmeLabel.layer.borderColor =  UIColor(red: 43/255.0, green: 66/255.0, blue: 143/255.0, alpha: 255.0/255.0).cgColor
       
  
       
       
        let cloudCredentials = CloudCredentials(appID: "dollani-bi1",
                                                appToken: "b62b4121000e11265883334fe1a89e13")
        // 2. Create the Proximity Observer
        self.proximityObserver = ProximityObserver(
            credentials: cloudCredentials,
            onError: { error in
                print("proximity observer error: \(error)")
            })
        
        updateTransition()
      
        
     
           
       
    }
    func  updateTransition(){
        let zone1 = ProximityZone(tag: "place 1", range: .far)
        let zone2 = ProximityZone(tag: "place 2", range: .far)
        let zone3 = ProximityZone(tag: "place 3", range: .far)
        let zone4 = ProximityZone(tag: "place 4", range: .far)
        
      
       
        // first zone
        zone1.onEnter = { context in
            AudioServicesPlaySystemSound(1352)
         self.getDirectionsFromPath()
            self.sourcePoint =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
         
            
            
        }
        
        
        //Second zone
        zone2.onEnter = { context in
            AudioServicesPlaySystemSound(1352)
           self.getDirectionsFromPath()
            self.sourcePoint =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
         
         
        
        }
      
        //Third zone
        zone3.onEnter = { context in
            AudioServicesPlaySystemSound(1352)
         self.getDirectionsFromPath()
            self.sourcePoint =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
         
         
        
        }
       
        //Fourth zone
        zone4.onEnter = { context in
            AudioServicesPlaySystemSound(1352)
             self.getDirectionsFromPath()
            self.sourcePoint =  CGPoint(x:Int(context.attachments["x"] as! String)! , y:    Int(context.attachments["y"] as! String)!)
         
         
        
        }
     
        
      
        
        self.proximityObserver.startObserving([zone1,zone2,zone3,zone4])
        
    }
    
    
    //MARK: - Navigation bar delegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
     return .topAttached
    }
    
    var nfcSession: NFCNDEFReaderSession?
    var word = "none"
    @IBAction func nfcreaderbtn(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
         
        
    }
    
    @objc func didTapReadNFC(){
        
    }
    
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("the session was invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        for payload in messages[0].records{
            result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf8) ?? "format not supported"
        }
        
        DispatchQueue.main.async {
         //   self.NFCmsg.text = result
            let alert = UIAlertController(title: "", message: result , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "حسنًا", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
}
    


