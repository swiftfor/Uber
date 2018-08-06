//
//  DriverViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Hamada on 7/29/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Parse
class DriverViewController: UITableViewController,CLLocationManagerDelegate {
   var driverUsername = [String]()
    var driverLocation = [CLLocationCoordinate2D]()
    var userlocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var locationManger = CLLocationManager()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutDriver"{
            locationManger.stopUpdatingLocation()
           PFUser.logOut()
            self.navigationController?.navigationBar.isHidden = true
        }
        else if  segue.identifier == "riderLocation"{
            if let destination = segue.destination as? RiderLocationViewController {
                if let row = tableView.indexPathForSelectedRow?.row {
                destination.requestLocation = driverLocation[row]
                destination.requestUsername = driverUsername[row]
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            userlocation = location
            let driverLocationQuery = PFQuery(className: "DriverLocation")
            driverLocationQuery.whereKey("username", equalTo: PFUser.current()?.username)
            driverLocationQuery.findObjectsInBackground { (objects, error) in
                if let driverLocations = objects {
                   
                        for driverlocation in driverLocations {
                            driverlocation["location"] = PFGeoPoint(latitude: self.userlocation.latitude, longitude: self.userlocation.longitude)
                            driverlocation.deleteInBackground()
                    }
                    
                        let driverLocation = PFObject(className: "DriverLocation")
                        driverLocation["username"] = PFUser.current()?.username
                        driverLocation["location"] = PFGeoPoint(latitude: self.userlocation.latitude, longitude: self.userlocation.longitude)
                        driverLocation.saveInBackground()
                    
                }
            }
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            query.limit = 10
            query.findObjectsInBackground { (objects, error) in
                if let riderRequests = objects {
                    self.driverUsername.removeAll()
                    self.driverLocation.removeAll()
                    for riderRequest in riderRequests {
                        if let username = riderRequest["username"] as? String{
                            if riderRequest["driverResponded"] == nil {
                            self.driverUsername.append(username)
                            self.driverLocation.append(CLLocationCoordinate2D(latitude: (riderRequest["location"] as AnyObject).latitude, longitude: (riderRequest["location"] as AnyObject).longitude))
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
                else
                {
                    print("No Results")
                }
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return driverUsername.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let driverCLLocation = CLLocation(latitude: userlocation.latitude, longitude: userlocation.longitude)
        let riderCLLocation = CLLocation(latitude: driverLocation[indexPath.row].latitude, longitude: driverLocation[indexPath.row].longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        cell.textLabel?.text = driverUsername[indexPath.row] + " - \(roundedDistance)Km away"

        return cell
    }
   
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
