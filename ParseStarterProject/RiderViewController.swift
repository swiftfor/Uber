//
//  RiderViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Hamada on 7/27/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit
class RiderViewController: UIViewController,MKMapViewDelegate , CLLocationManagerDelegate {
    func alertController(_ title : String , _ message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    var driverOnWay = false
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var userLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout"
        {
            locationManager.stopUpdatingLocation()
            PFUser.logOut()
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects
            {
                if objects.count > 0 {
               self.riderRequestActive = true
                self.cellAnUberOutlet.setTitle("Cancel Uber", for: [])
            }
            }
            self.cellAnUberOutlet.isHidden = false
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            if driverOnWay == false {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            self.map.setRegion(region, animated: true)
            self.map.removeAnnotations(self.map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation
            annotation.title = "Your Current Location"
            self.map.addAnnotation(annotation)
            }
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground { (objects, error) in
                if let riderRequests = objects
                {
                    for riderRequest in riderRequests
                    {
                        riderRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        riderRequest.saveInBackground()
                    }
                }
            }
        }
        if riderRequestActive == true {
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: PFUser.current()?.username)
            query.findObjectsInBackground { (objects, error) in
                if let riderRequests = objects {
                    for riderRequest in riderRequests {
                        if let driverUsername = riderRequest["driverResponded"]{
                            let query = PFQuery(className: "DriverLocation")
                            query.whereKey("username", equalTo: driverUsername)
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let driverLocations = objects {
                                    for driverLocationObject in driverLocations {
                                        if let driverLocation = driverLocationObject["location"] as? PFGeoPoint {
                                            self.driverOnWay = true
                                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            let riderCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            let distance = riderCLLocation.distance(from: driverCLLocation) / 1000
                                            let roundedDistance = round(distance * 100) / 100
                                            self.cellAnUberOutlet.setTitle("Your Driver is \(roundedDistance)km away!", for: [])
                                            let latDelta = abs(driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            let lonDelta = abs(driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            let span =  MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                                            let region = MKCoordinateRegion(center: self.userLocation, span: span)
                                            self.map.removeAnnotations(self.map.annotations)
                                            self.map.setRegion(region, animated: true)
                                            let userLocationAnnotation = MKPointAnnotation()
                                            userLocationAnnotation.coordinate = self.userLocation
                                            userLocationAnnotation.title = "Your Location"
                                            
                                            self.map.addAnnotation(userLocationAnnotation)
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            driverLocationAnnotation.title = "your driver"
                                            self.map.addAnnotation(driverLocationAnnotation)
                                        }
                                        
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    var riderRequestActive =  true
    @IBOutlet weak var cellAnUberOutlet: UIButton!
    @IBAction func cellAnUber(_ sender: Any) {
        if riderRequestActive
        {
            self.cellAnUberOutlet.setTitle("Call An Uber", for: [])
            riderRequestActive = false
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground { (objects, error) in
                if let riderRequests = objects
                {
                    for riderRequest in riderRequests
                    {
                        riderRequest.deleteInBackground()
                    }
                }
            }
        }
        else
        {
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
                self.cellAnUberOutlet.setTitle("Cancel Uber", for: [])
                riderRequestActive = true
                let riderRequest = PFObject(className: "RiderRequest")
                riderRequest["username"] = PFUser.current()?.username
                riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                riderRequest.saveInBackground { (success, error) in
                    if success
                    {
                        print("Call Uber")
                    }
                    else
                    {
                        self.alertController("couldnot cell uber", "Please try again later!")
                        self.cellAnUberOutlet.setTitle("Cancel Uber", for: [])
                        self.riderRequestActive = true
                    }
                }
            }
            else
            {
                alertController("Coudnot cell uber", "cannot detect your location")
            }
            
        }
        }
        
}
