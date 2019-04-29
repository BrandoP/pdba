//
//  ViewController.swift
//  GyroFinal
//
//  Created by Brandon Piller on 2018-06-27.
//  Copyright © 2018 Brandon Piller. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    //Instruction view
    @IBOutlet var imageView : UIImageView!
    
    //Home view
    @IBOutlet weak var MainView: UIImageView!
    
    //Button that links to website
    @IBOutlet weak var LinkBtn: UIButton!
    
    //make a manager to allow use access to motion
    let manager = CMMotionManager()
    
    // the variable to determine if can turn to next page
    var canTurn = false
    
    var pressedHome = false
    var pressedInfo = false
    
    var i=Int()
    
    //List of the instruction and main views
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vcInfo1 = sb.instantiateViewController(withIdentifier: "imageGallery")
        let vcInfo2 = sb.instantiateViewController(withIdentifier: "HomeVC")
        
        return [vcInfo1,vcInfo2]
    }()
    
    //Array of instruction images
    var instructionImages: [UIImage] = [
        UIImage(named: "01-instructions.jpg")!,
        UIImage(named: "02-instructions.jpg")!,
        UIImage(named: "03-instructions.jpg")!,
        UIImage(named: "04-instructions.jpg")!
    ]
    
    //Array of project images
    var soulImages: [UIImage] = [
        UIImage(named: "SoulSearching_0000_Layer 1.jpg")!,
        UIImage(named: "SoulSearching_0001_Layer 2.jpg")!,
        UIImage(named: "SoulSearching_0002_Layer 3.jpg")!,
        UIImage(named: "SoulSearching_0003_Layer 4.jpg")!,
        UIImage(named: "SoulSearching_0004_Layer 5.jpg")!,
        UIImage(named: "SoulSearching_0005_Layer 6.jpg")!,
        UIImage(named: "SoulSearching_0006_Layer 7.jpg")!,
        UIImage(named: "SoulSearching_0007_Layer 8.jpg")!,
        UIImage(named: "SoulSearching_0008_Layer 9.jpg")!,
        UIImage(named: "SoulSearching_0009_Layer 10.jpg")!,
        UIImage(named: "SoulSearching_0010_Layer 11.jpg")!,
        UIImage(named: "SoulSearching_0011_Layer 12.jpg")!,
        UIImage(named: "SoulSearching_0012_Layer 13.jpg")!,
        UIImage(named: "SoulSearching_0013_Layer 14.jpg")!,
        UIImage(named: "SoulSearching_0014_Layer 15.jpg")!,
        UIImage(named: "SoulSearching_0015_Layer 16.jpg")!,
        UIImage(named: "SoulSearching_0017_Layer 18.jpg")!,
        UIImage(named: "SoulSearching_0018_Layer 19.jpg")!
    ]
    
    
    override func viewDidLoad() {
        canTurn = false
        super.viewDidLoad()
        
        //Start the timer and function for instruction images to automatically switch
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        canTurn = false
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
    }
    
    //Use updateViewConstraints to update constantly
    override func updateViewConstraints(){
        super.updateViewConstraints()
        
        self.navigationController?.navigationBar.isHidden = true
    
        //Check to make sure that motion is available
        if manager.isDeviceMotionAvailable{
            
            //Sets how often the gyro values are checked
            manager.gyroUpdateInterval = 0.02
            manager.startGyroUpdates()
    
            //Initialize the index to go through the array with
            var index = 0{
                didSet{
                    //print("index changed to \(index)")
                }
            }
            
            self.canTurn = false
    
            let queue = OperationQueue.main
            
            //Begin to execute code with device motions
            manager.startDeviceMotionUpdates(to: queue){
                [weak self] (data:CMDeviceMotion?, error:Error?) in
    
                //create a constant variable to contain all the motion data
                guard let data = data else {return}

                //Get the yaw and roll in terms of degrees
                let yawDegrees = data.attitude.yaw * (180.0 / .pi);
                let rollDegrees = data.attitude.roll * (180.0 / .pi);
                
                print("Raw roll",data.attitude.roll)
                print("rolldegrees", rollDegrees)
                
                //If the image with the link appears, allow clickable button for link to appear
                if(self?.MainView?.image == UIImage(named: "SoulSearching_0017_Layer 18.jpg")){
                    self?.LinkBtn?.isHidden = false
                }else{
                    self?.LinkBtn?.isHidden = true
                }
    
                //A switch statment that takes the rotation degrees(Double), index(int) and canTurn(bool) as parameters
                switch (rollDegrees, index, self?.canTurn){
                    
                    //Case where roll degress is between 100 and infinity, index is less then
                //soulImages number of items and canTurn is true.
                case (150...Double(Int.max),1...Int.max, true):
                    //set canTurn to false so index only decrements once
                    self?.canTurn = false
                    
                    index -= 1
                    self?.MainView?.image = self?.soulImages[index]
                    
                    //Same as prior case except going the other direction
                //so if rotation degrees is less than -100 and index is greater than zero
                case (Double(Int.min) ..< -150,Int.min...(self?.soulImages.count)! - 2, true):
                    self?.canTurn = false
                    
                    //If the view is the instruction view, rotation changes to the MainView
                    if self?.navigationController?.visibleViewController?.title == "Instruction"{
                       
                        let view = self?.viewControllerList[1]
                        self?.navigationController?.popViewController(animated: false)
                        self?.navigationController?.pushViewController(view!, animated: false)
                    }else{
                      
                        index += 1
                        self?.MainView?.image = self?.soulImages[index]
                    }
                    
                //If the rotation degrees is inbetween -50 and 50( facing forward), inbetween
                //the index range and canTurn is false
                case (-50...50,0...(self?.soulImages.count)! - 1, false):
                    
                    //Reset the canTurn variable so the image can change once rotated
                    self?.canTurn = true
                
                    
                //Keep from canTrue flipping from true and false
                case (-150...150,0...(self?.soulImages.count)! - 1, true):
                    self?.canTurn = true

                    
                //Default case
                default:
                    self?.canTurn = false
                }
            }
        }
    }
    
    //Go back to the first view
    @IBAction func HomeBtn(_ sender: UIButton) {
        //print("Home button has been pressed")

        if self.navigationController?.visibleViewController?.title == "Instruction"{
            let view = self.viewControllerList[1]
            self.MainView?.image = self.soulImages[0]
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(view, animated: false)
        }
        self.MainView?.image = self.soulImages[0]
        pressedHome = true
        canTurn = true
        pressedInfo = false
    }
    
    //Changes to the instruction views
    @IBAction func InfoBtn(_ sender: UIButton) {
        let view = self.viewControllerList[0]
        self.imageView?.image = instructionImages[0]
        
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(view, animated: false)
        pressedInfo = true
    }
    
    //Automatic function the changes image in imageView
    @objc func changeImage(){
        
        self.imageView?.image = instructionImages[i]
        
        //increase i if less that the number of instruction images, otherwise set i to 0
        if i<instructionImages.count-1{
            i+=1
        }
        else{
            i=0
        }
    }
    
    //Click on button to open link
    @IBAction func didTapLink(sender: AnyObject) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "http://pdba.usask.ca/")!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "http://pdba.usask.ca/")!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
