//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Marko Budal on 27/01/15.
//  Copyright (c) 2015 Marko Budal. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //UICollectionDataSorce
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell: FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        //ce je celica == nil naredi sliko, ce ni pa pusti (to se spreminja vsakic pri scrolanju)
      //  if cell.imageView.image == nil {  // to smo resli z kesom
            cell.imageView.image = placeHolderImage
            
            let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            
            dispatch_async(filterQueue, { () -> Void in
                
                //let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])
                let filterImage = self.getCachedImage(indexPath.row)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
      //  }
        
        return cell
    }
    
    
    //UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        createUIAlertController(indexPath)
       
    }
    
    
    //Helper Function
    func photoFilters() -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorClamp, sepia, vignette]
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filterImage:CIImage = filter.outputImage
        
        let extent = filterImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filterImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    //UIAlertController Helper Functions
    
    func createUIAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        let textField = alert.textFields![0] as UITextField
        
        let photoAction = UIAlertAction(title: "Post Photo to facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in

            self.shareToFacebook(indexPath)
            var text = textField.text
            
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        
        let savaFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            var text = textField.text
            
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            
        }
       
        
        alert.addAction(photoAction)
        alert.addAction(savaFilterAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveFilterToCoreData(indexPath:NSIndexPath, caption: String){
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        self.thisFeedItem.caption = caption
        self.thisFeedItem.filtereed = true
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func shareToFacebook (indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        let photos:NSArray = [filterImage]
        var params = FBPhotoParams()
        params.photos = photos
        
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, results, error) -> Void in
            if results != nil {
                println(results)
            }else{
                println(error)
            }
        }
        
    }
    

    //caching function
    func cacheImage(imageNumber:Int) {
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            var returnedImage = UIImage(contentsOfFile: uniquePath)!
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!
        }else{
            self.cacheImage(imageNumber)
            var returnedImage = UIImage(contentsOfFile: uniquePath)!
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!
        }
        
        return image
    }
}
