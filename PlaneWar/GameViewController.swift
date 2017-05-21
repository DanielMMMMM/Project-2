//
//  GameViewController.swift
//  PlaneShooter
//
//  Created by feng on 5/16/17.
//  Copyright (c) 2017 feng. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file as String, ofType: "sks")
        
        do {
            let sceneData: Data = try Data(contentsOf: URL(fileURLWithPath: path!), options: NSData.ReadingOptions.mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
            
        } catch {
            
        }
        return nil
    }
}

class GameViewController: UIViewController {

    var restartButton:UIButton!
    var pauseButton:UIButton!
    var continueButton:UIButton!
    var rankingButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            scene.size = view.frame.size
            
            skView.presentScene(scene)
            
            // add button
            initButton()
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.gameOver), name: NSNotification.Name(rawValue: "gameOverNotification"), object: nil)
            
        }
    }
    
    func initButton(){
        let buttonImage = UIImage(named:"BurstAircraftPause")!
        
        pauseButton = UIButton()
        pauseButton.frame = CGRect(x: 10, y: 25, width: buttonImage.size.width, height: buttonImage.size.height)
        pauseButton.setBackgroundImage(buttonImage, for: UIControlState())
        pauseButton.addTarget(self, action: #selector(GameViewController.pause), for: .touchUpInside)
        view.addSubview(pauseButton)
        
        restartButton = UIButton()
        restartButton.bounds = CGRect(x: 0, y: 0, width: 200, height: 30)
        restartButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + 30)
        restartButton.isHidden = true
        restartButton.setTitle("restart", for: UIControlState())
        restartButton.setTitleColor(UIColor.black, for: UIControlState())
        restartButton.layer.borderWidth = 2.0
        restartButton.layer.cornerRadius = 15.0
        restartButton.layer.borderColor = UIColor.gray.cgColor
        restartButton.addTarget(self, action: #selector(GameViewController.restart(_:)), for: .touchUpInside)
        view.addSubview(restartButton)
        
        rankingButton = UIButton()
        rankingButton.bounds = CGRect(x: 0, y: 0, width: 200, height: 30)
        rankingButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + 30)
        rankingButton.isHidden = true
        rankingButton.setTitle("ranking", for: UIControlState())
        rankingButton.setTitleColor(UIColor.black, for: UIControlState())
        rankingButton.layer.borderWidth = 2.0
        rankingButton.layer.cornerRadius = 15.0
        rankingButton.layer.borderColor = UIColor.gray.cgColor
        rankingButton.addTarget(self, action: #selector(GameViewController.ranking(_:)), for: .touchUpInside)
        view.addSubview(rankingButton)
        
        continueButton = UIButton()
        continueButton.bounds = CGRect(x: 0, y: 0, width: 200, height: 30)
        continueButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 - 30)
        continueButton.isHidden = true
        continueButton.setTitle("continue", for: UIControlState())
        continueButton.setTitleColor(UIColor.black, for: UIControlState())
        continueButton.layer.borderWidth = 2.0
        continueButton.layer.cornerRadius = 15.0
        continueButton.layer.borderColor = UIColor.gray.cgColor
        continueButton.addTarget(self, action: #selector(GameViewController.continueGame(_:)), for: .touchUpInside)
        view.addSubview(continueButton)


    }

    func gameOver(info:NSNotification){
//        let backgroundView = UIView(frame:CGRect)
        
//        let dic = info.userInfo! as NSDictionary
        restartButton.center.x = view.center.x
        restartButton.center.y = view.center.y - 20
        restartButton.isHidden = false
        rankingButton.center.x = view.center.x
        rankingButton.center.y = view.center.y + 20
        rankingButton.isHidden = false
        view.addSubview(restartButton)
        view.addSubview(rankingButton)
        view.center = view.center
//        view.addSubview(backgroundView)
    }
    
    func pause(){
        (view as! SKView).isPaused = true
        restartButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 + 30)
        continueButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2 - 30)
        restartButton.isHidden = false
        continueButton.isHidden = false
        
    }
    
    func restart(_ button:UIButton){
        restartButton.isHidden = true
        continueButton.isHidden = true
        rankingButton.isHidden = true
        self.becomeFirstResponder()
        (view as! SKView).isPaused = false
        NotificationCenter.default.post(name: Notification.Name(rawValue: "restartNotification"), object: nil)
        
    }
    
    func ranking(_ button:UIButton) {
        let vc = RankingTableViewController.init(nibName: "RankingTableViewController", bundle: nil)
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func continueGame(_ button:UIButton){
        continueButton.isHidden = true
        restartButton.isHidden = true
        rankingButton.isHidden = true
        (view as! SKView).isPaused = false
    }
   
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool
    {
        return true
    }
    
  
    
    
}
