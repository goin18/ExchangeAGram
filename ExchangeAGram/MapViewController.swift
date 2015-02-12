//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Marko Budal on 09/02/15.
//  Copyright (c) 2015 Marko Budal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var error:NSError?
        let itemArray = context.executeFetchRequest(request, error: &error)
        println("Error: \(error)")
        
        if itemArray!.count > 0 {
        
            for item in itemArray! {
                let location = CLLocationCoordinate2DMake(Double(item.latitude), Double(item.longitude))
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let rigion = MKCoordinateRegionMake(location, span)
                
                mapView.setRegion(rigion, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(location)
                annotation.title = item.caption
                
                mapView.addAnnotation(annotation)
            }
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
