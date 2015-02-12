//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Marko Budal on 25/01/15.
//  Copyright (c) 2015 Marko Budal. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit


class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var feedArray:[AnyObject] = []
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "AutumnBackground")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        
        
        
        // Do any additional setup after loading the view.
           }
    
    override func viewDidAppear(animated: Bool) {
        
        var request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!

        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("profileSeque", sender: nil)
    }
    
    @IBAction func snapbarButtonTapped(sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
        }else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaType:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaType
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
            
        }else{
        
            var alertView = UIAlertController(title: "Alert", message: "Your device does not support the camera or the photo lib.", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    //UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
        
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managentObjectContext = appDelegate.managedObjectContext
        let entityDecription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managentObjectContext!)
        
        let feedItem = FeedItem(entity: entityDecription!, insertIntoManagedObjectContext: managentObjectContext!)
        
        feedItem.image = imageData
        feedItem.caption = "test caption"
        feedItem.thumbNail = thumbNailData
        
        feedItem.latitude = locationManager.location.coordinate.latitude
        feedItem.longitude = locationManager.location.coordinate.longitude
        
        let UUID = NSUUID().UUIDString
        feedItem.uniqueID = UUID
        
        feedItem.filtereed = false
        
        appDelegate.saveContext()
        
        
        feedArray.append(feedItem)
        self.collectionView.reloadData()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return feedArray.count
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
        let feedItem = feedArray[indexPath.row] as FeedItem
        
        if feedItem.filtereed == true {
            let returnedImage = UIImage(data: feedItem.image)
            let image = UIImage(CGImage: returnedImage?.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)
        }else{
            cell.imageView.image = UIImage(data: feedItem.image)
        }
        
        
        cell.captionLabel.text = feedItem.caption
        
        return cell
    }
    
    //UICollectionVewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as FeedItem
    
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Locations: \(locations)")
    }
    

}
