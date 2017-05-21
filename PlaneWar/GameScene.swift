//
//  GameScene.swift
//  PlaneShooter
//
//  Created by feng on 5/16/17.
//  Copyright (c) 2017 feng. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var heroPlane:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var pauseButton:SKSpriteNode!
    
    var smallPlaneHitAction:SKAction!
    var smallPlaneBlowUpAction:SKAction!
    var mediumPlaneHitAction:SKAction!
    var mediumPlaneBlowUpAction:SKAction!
    var largePlaneHitAction:SKAction!
    var largePlaneBlowUpAction:SKAction!
    var heroPlaneBlowUpAction:SKAction!
    
    var scoreArray:Array<Int> = []
    
    var score:Int = 0
    
    
    enum RoleCategory:UInt32{
        case bullet = 1
        case heroPlane = 2
        case enemyPlane = 4
    }
    
    override func didMove(to view: SKView) {
        initBackground()
        initActions()
        initHeroPlane()
        initEnemyPlane()
        initScoreLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.restart), name: NSNotification.Name(rawValue: "restartNotification"), object: nil)
    }
    
    func restart(){
        removeAllChildren()
        removeAllActions()
        
        initBackground()
        initScoreLabel()
        initHeroPlane()
        initEnemyPlane()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch : AnyObject! = (touches as NSSet).anyObject() as AnyObject
        let location = anyTouch.location(in: self)
        heroPlane.run(SKAction.move(to: location, duration: 0.1))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch : AnyObject! = (touches as NSSet).anyObject() as AnyObject
        let location = anyTouch.location(in: self)
        heroPlane.run(SKAction.move(to: location, duration: 0))
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func initBackground()
    {
        // init texture
        let backgroundTexture = SKTexture(imageNamed:"background")
        backgroundTexture.filteringMode = .nearest
        
        // set action
        
        let moveBackgroundSprite = SKAction.moveBy(x: 0, y:-backgroundTexture.size().height, duration: 5)
        let resetBackgroundSprite = SKAction.moveBy(x: 0, y:backgroundTexture.size().height, duration: 0)
        let moveBackgroundForever = SKAction.repeatForever(SKAction.sequence([moveBackgroundSprite,resetBackgroundSprite]))
        
        // init background sprite
        
        for index in 0..<2 {
            
            let backgroundSprite = SKSpriteNode(texture:backgroundTexture)
            backgroundSprite.position = CGPoint(x: size.width/2,y: size.height / 2 + CGFloat(index) * backgroundSprite.size.height)
            backgroundSprite.zPosition = 0
            backgroundSprite.run(moveBackgroundForever)
            addChild(backgroundSprite)
        }
        
        // play background music
        run(SKAction.repeatForever(SKAction.playSoundFileNamed("game_music.mp3", waitForCompletion: true)))
        
        // set physics world
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
    }
    
    func initActions()
    {
        // small hit action
        // nil
        
        
        
        // small blow up action
        var smallPlaneBlowUpTexture = [SKTexture]()
        for i in 1...4 {
            smallPlaneBlowUpTexture.append(SKTexture(imageNamed:"enemy1_blowup_\(i)"))
        }
        smallPlaneBlowUpAction = SKAction.sequence([SKAction.animate(with: smallPlaneBlowUpTexture, timePerFrame: 0.03),SKAction.removeFromParent()])
        
        // medium hit action
        var mediumPlaneHitTexture = [SKTexture]()
        mediumPlaneHitTexture.append(SKTexture(imageNamed:"enemy3_hit_1"))
        mediumPlaneHitTexture.append(SKTexture(imageNamed:"enemy3_fly_1"))
        mediumPlaneHitAction = SKAction.animate(with: mediumPlaneHitTexture, timePerFrame: 0.1)
        
        // medium blow up action
        var mediumPlaneBlowUpTexture = [SKTexture]()
        for i in 1...4 {
            mediumPlaneBlowUpTexture.append(SKTexture(imageNamed:"enemy3_blowup_\(i)"))
        }
        mediumPlaneBlowUpAction = SKAction.sequence([SKAction.animate(with: mediumPlaneBlowUpTexture, timePerFrame: 0.05),SKAction.removeFromParent()])
        
        // large hit action
        var largePlaneHitTexture = [SKTexture]()
        largePlaneHitTexture.append(SKTexture(imageNamed:"enemy2_hit_1"))
        largePlaneHitTexture.append(SKTexture(imageNamed:"enemy2_fly_2"))
        largePlaneHitAction = SKAction.animate(with: largePlaneHitTexture, timePerFrame: 0.1)
        
        // large blow up action
        var largePlaneBlowUpTexture = [SKTexture]()
        for i in 1...7 {
            largePlaneBlowUpTexture.append(SKTexture(imageNamed:"enemy2_blowup_\(i)"))
        }
        largePlaneBlowUpAction = SKAction.sequence([SKAction.animate(with: largePlaneBlowUpTexture, timePerFrame: 0.1),SKAction.removeFromParent()])
        
        // hero plane blow up action
        var heroPlaneBlowUpTexture = [SKTexture]()
        for i in 1...4 {
            heroPlaneBlowUpTexture.append(SKTexture(imageNamed:"hero_blowup_\(i)"))
        }
        heroPlaneBlowUpAction = SKAction.sequence([SKAction.animate(with: heroPlaneBlowUpTexture, timePerFrame: 0.1),SKAction.removeFromParent()])
        
    }
    
    func initScoreLabel()
    {
        scoreLabel = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        
        scoreLabel.text = "0000"
        scoreLabel.zPosition = 2
        scoreLabel.fontColor = SKColor.black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 50, y: size.height - 52)
        addChild(scoreLabel)
    }
    
    func changeScore(_ type:EnemyPlaneType)
    {
        var score:Int
        switch type {
        case .large:
            score = 30000
        case .medium:
            score = 6000
        case .small:
            score = 1000
        }
        
        scoreLabel.run(SKAction.run({() in
            self.scoreLabel.text = "\(Int(self.scoreLabel.text!)! + score)"}))
        
    }
    
    func initHeroPlane()
    {
        let heroPlaneTexture1 = SKTexture(imageNamed:"hero_fly_1")
        let heroPlaneTexture2 = SKTexture(imageNamed:"hero_fly_2")
        
        heroPlane = SKSpriteNode(texture:heroPlaneTexture1)
        heroPlane.setScale(0.5)
        
        heroPlane.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        heroPlane.zPosition = 1
        let heroPlaneAction = SKAction.animate(with: [heroPlaneTexture1,heroPlaneTexture2], timePerFrame: 0.1)
        heroPlane.run(SKAction.repeatForever(heroPlaneAction))
        
        heroPlane.physicsBody = SKPhysicsBody(texture:heroPlaneTexture1,size:heroPlane.size)
        heroPlane.physicsBody?.allowsRotation = false
        heroPlane.physicsBody?.categoryBitMask = RoleCategory.heroPlane.rawValue
        heroPlane.physicsBody?.collisionBitMask = 0
        heroPlane.physicsBody?.contactTestBitMask = RoleCategory.enemyPlane.rawValue
        
        addChild(heroPlane)
        
        // fire bullets
        let spawn = SKAction.run{() in
            self.createBullet()}
        let wait = SKAction.wait(forDuration: 0.2)
        heroPlane.run(SKAction.repeatForever(SKAction.sequence([spawn,wait])))
        
    }
    
    func createBullet()
    {
        let bulletTexture = SKTexture(imageNamed:"bullet1")
        let bullet = SKSpriteNode(texture:bulletTexture)
        bullet.setScale(0.5)
        bullet.position = CGPoint(x: heroPlane.position.x, y: heroPlane.position.y + heroPlane.size.height/2 + bullet.size.height/2)
        bullet.zPosition = 1
        let bulletMove = SKAction.moveBy(x: 0, y: size.height, duration: 0.5)
        let bulletRemove = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([bulletMove,bulletRemove]))
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        //bullet.physicsBody = SKPhysicsBody(texture:bulletTexture,size:bullet.size)
        bullet.physicsBody?.allowsRotation = false
        bullet.physicsBody?.categoryBitMask = RoleCategory.bullet.rawValue
        bullet.physicsBody?.collisionBitMask = RoleCategory.enemyPlane.rawValue
        bullet.physicsBody?.contactTestBitMask = RoleCategory.enemyPlane.rawValue
        
        addChild(bullet)
        
        // play bullet music
        
        run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
        
    }
    
    func initEnemyPlane()
    {
        let spawn = SKAction.run{() in
            self.createEnemyPlane()}
        let wait = SKAction.wait(forDuration: 0.4)
        run(SKAction.repeatForever(SKAction.sequence([spawn,wait])))
    }
    
    func createEnemyPlane(){
        let choose = arc4random() % 100
        var type:EnemyPlaneType
        var speed:Float
        var enemyPlane:EnemyPlane
        switch choose
        {
        case 0..<75:
            type = .small
            speed = Float(arc4random() % 3) + 2
            enemyPlane = EnemyPlane.createSmallPlane()
            
        case 75..<97:
            type = .medium
            speed = Float(arc4random() % 3) + 4
            enemyPlane = EnemyPlane.createMediumPlane()
        case _:
            type = .large
            speed = Float(arc4random() % 3) + 6
            enemyPlane = EnemyPlane.createLargePlane()
            run(SKAction.playSoundFileNamed("enemy2_out.mp3", waitForCompletion: false))
        }
        
        enemyPlane.zPosition = 1
        enemyPlane.physicsBody?.isDynamic = false
        enemyPlane.physicsBody?.allowsRotation = false
        enemyPlane.physicsBody?.categoryBitMask = RoleCategory.enemyPlane.rawValue
        enemyPlane.physicsBody?.collisionBitMask = RoleCategory.bullet.rawValue | RoleCategory.heroPlane.rawValue
        enemyPlane.physicsBody?.contactTestBitMask = RoleCategory.bullet.rawValue | RoleCategory.heroPlane.rawValue
        
        let x = (arc4random() % 220) + 35
        enemyPlane.position = CGPoint(x: CGFloat(x), y: size.height + enemyPlane.size.height/2)
        
        let moveAction = SKAction.moveTo(y: 0, duration: TimeInterval(speed))
        let remove = SKAction.removeFromParent()
        enemyPlane.run(SKAction.sequence([moveAction,remove]))
        
        addChild(enemyPlane)
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        
        let enemyPlane = (contact.bodyA.categoryBitMask & RoleCategory.enemyPlane.rawValue) == RoleCategory.enemyPlane.rawValue
            ? (contact.bodyA.node as! EnemyPlane) : (contact.bodyB.node as! EnemyPlane)
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == RoleCategory.enemyPlane.rawValue | RoleCategory.bullet.rawValue
        {
            
            // hit bullet
            let bullet = contact.bodyA.categoryBitMask & RoleCategory.bullet.rawValue == RoleCategory.bullet.rawValue ? contact.bodyA.node as! SKSpriteNode : contact.bodyB.node as! SKSpriteNode
            
            bullet.run(SKAction.removeFromParent())
            enemyPlaneCollision(enemyPlane)
            
        }
        else if collision == RoleCategory.enemyPlane.rawValue | RoleCategory.heroPlane.rawValue
        {
            
            print("hit plane")
            // hit hero plane
            let heroPlane = contact.bodyA.categoryBitMask & RoleCategory.heroPlane.rawValue == RoleCategory.heroPlane.rawValue ? contact.bodyA.node as! SKSpriteNode : contact.bodyB.node as! SKSpriteNode
            heroPlane.run(heroPlaneBlowUpAction,completion:{() in
                self.run(SKAction.sequence([
                    SKAction.playSoundFileNamed("game_over.mp3", waitForCompletion: true),
                    SKAction.run({() in
                        let label = SKLabelNode(fontNamed:"MarkerFelt-Thin")
                        label.text = "GameOver"
                        label.zPosition = 2
                        label.fontColor = SKColor.black
                        label.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 40)
                        self.addChild(label)
                    })
                    ])
                    ,completion:{() in
                        self.resignFirstResponder()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "gameOverNotification"), object: nil, userInfo: ["score":self.scoreLabel.text ?? "100"])
                        
                        self.scoreArray = UserDefaults.standard.value(forKey: "scoreArray") as! Array<Int>
                        
                        self.scoreArray.sort{ (n1: Int, n2: Int) -> Bool in
                            //进行从小到大的排序
                            return n2 < n1
                        }
                        
                        let currentScore = Int(self.scoreLabel.text!)
                        if self.score == currentScore! {
                            return;
                        }
                        self.score = currentScore!
                        if self.scoreArray.count >= 3 {
                            for score in self.scoreArray {
                                if currentScore! > score {
                                    self.scoreArray.removeLast()
                                    self.scoreArray.append(currentScore!)
                                }
                            }
                        } else if self.scoreArray.count > 0 && self.scoreArray.count < 3 {
                            var isSame = false
                            for score:Int in self.scoreArray {
                                if currentScore! == score {
                                    isSame = true
                                }
                            }
                            
                            if isSame == false {
                                self.scoreArray.append(currentScore!)
                            }
                            
                        } else if self.scoreArray.count == 0 {
                            self.scoreArray.append(currentScore!)
                        }
                        
                        self.scoreArray.sort{ (n1: Int, n2: Int) -> Bool in
                            //进行从小到大的排序
                            return n2 < n1
                        }
                        UserDefaults.standard.set(self.scoreArray, forKey: "scoreArray")
                        UserDefaults.standard.synchronize()
                    }
                )}
            )
        }
    }
    
    func enemyPlaneCollision(_ enemyPlane:EnemyPlane)
    {
        enemyPlane.hp -= 1
        if enemyPlane.hp < 0 {
            enemyPlane.hp = 0
        }
        if enemyPlane.hp > 0 {
            switch enemyPlane.type{
            case .small:
                enemyPlane.run(smallPlaneHitAction)
            case .large:
                enemyPlane.run(largePlaneHitAction)
            case .medium:
                enemyPlane.run(mediumPlaneHitAction)
            }
            
        } else {
            switch enemyPlane.type{
            case .small:
                changeScore(.small)
                enemyPlane.run(smallPlaneBlowUpAction)
                run(SKAction.playSoundFileNamed("enemy1_down.mp3", waitForCompletion: false))
            case .large:
                changeScore(.large)
                enemyPlane.run(largePlaneBlowUpAction)
                run(SKAction.playSoundFileNamed("enemy2_down.mp3", waitForCompletion: false))
            case .medium:
                changeScore(.medium)
                enemyPlane.run(mediumPlaneBlowUpAction)
                run(SKAction.playSoundFileNamed("enemy3_down.mp3", waitForCompletion: false))
            }
        }
    }
}
