//
//  ViewController.swift
//  04-CoreLocation-Weather-CoreData
//
//  Created by Gianfranco Cotumaccio on 23/06/16.
//  Copyright © 2016 Propaganda Studio. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Variables
    var locationManager = CLLocationManager()
    var networkReachability = NetworkReachabilityManager(host: "openweathermap.org")
    
    // CoreData
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("ERROR: \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locationManager.location
        
        if currentLocation != nil {
            let lat = (currentLocation?.coordinate.latitude)!
            let lon = (currentLocation?.coordinate.longitude)!
            
            if networkReachability?.isReachable != false {
                print("Reachable")
                Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=fc5edb9fa5d86243573c9a9fc26f8d86").validate().responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .Success:
                        let json = JSON(response.result.value!)
                        let context = self.appDelegate.managedObjectContext
                        let weather = NSEntityDescription.insertNewObjectForEntityForName("Weather", inManagedObjectContext: context)
                        weather.setValue(json["name"].string, forKey: "cityName")
                        weather.setValue(json["weather"][0]["description"].string, forKey: "weatherDescription")
                        
                        if context.hasChanges {
                            do {
                                try context.save()
                            }
                            catch {
                                print("ERROR!")
                            }
                        }
                        
                        print(json)
                    case .Failure(let error):
                        print(error)
                    }
                })
            } else {
                print("Not Reachable")
                let context = self.appDelegate.managedObjectContext
                let request = NSFetchRequest(entityName: "Weather")
                request.returnsObjectsAsFaults = false
                var results = [NSManagedObject]()
                do {
                    results = try context.executeFetchRequest(request) as! [NSManagedObject]
                    if results.count > 0 {
                        print("City: \(results[0].valueForKey("cityName")!)")
                        print("Description: \(results[0].valueForKey("weatherDescription")!)")
                    }
                } catch let error as NSError {
                    print("Error: \(error.debugDescription)")
                }
            }
            
        }
        
        manager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

