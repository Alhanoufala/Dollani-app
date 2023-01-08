//
//  mapViewController.swift
//  Dollani
//
//  Created by Layan Alwadie on 15/06/1444 AH.
//

import UIKit
import MapKit
class mapViewController: UIViewController {

    
    var VIname = "سارة"
    var VICurrentLocation = "كلية الحاسب"
    var lat = 24.78035151530207
    var lng = 46.69827115693956

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLoc = CLLocation(latitude: 24.774265, longitude: 46.738586)
        setStartingLocation(location: initialLoc, distance: 10000)
        addAnnotation()
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    func setStartingLocation(location: CLLocation, distance: CLLocationDistance){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: true)
    }
    func addAnnotation(){
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        pin.title = VIname
        pin.subtitle = VICurrentLocation
        mapView.addAnnotation(pin)
    }
    

}
