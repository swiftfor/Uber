//
//  RiderLocationViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Hamada on 7/29/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse
class RiderLocationViewController: UIViewController,MKMapViewDelegate {
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestUsername = ""
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptRequestOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestUsername
        map.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func acceptRequestButton(_ sender: Any) {
        let query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: requestUsername)
        query.findObjectsInBackground { (objects, error) in
            if let riderRequests = objects {
                for riderReduqest in riderRequests {
                    riderReduqest["driverResponded"] = PFUser.current()?.username
                    riderReduqest.saveInBackground()
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        if let placemarks = placemarks {
                            if placemarks.count > 0 {
                                let mKplacemarks = MKPlacemark(placemark: placemarks[0])
                                let mapItem = MKMapItem(placemark: mKplacemarks)
                                mapItem.name = self.requestUsername
                                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                mapItem.openInMaps(launchOptions: launchOptions)
                            }
                        }
                    })
                    
                }
            }
        }
    }
    

}
