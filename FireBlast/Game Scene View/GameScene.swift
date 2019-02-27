//
//  GameScene.swift
//  FireBlast
//
//  Created by Gavin Waite on 11/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//


import Foundation
import SpriteKit
import UIKit
import GameplayKit
import AudioToolbox
import AVFoundation // for quiter sounds hopefully

// Convenience Constants

// SKAction shortcuts
let fire = SKAction.moveTo(y: 20, duration: 2)
let fireFast = SKAction.moveTo(y: 20, duration: 1)
let death = SKAction.removeFromParent()
let wait = SKAction.wait(forDuration: 4)
let explode = SKAction.sequence([wait, death])



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    
    
    
    //https://developer.apple.com/library/prerelease/ios/documentation/SpriteKit/Reference/SKPhysicsBody_Ref/#//apple_ref/occ/instp/SKPhysicsBody/collisionBitMask
    //http://www.techotopia.com/index.php/A_Swift_iOS_8_Sprite_Kit_Collision_Handling_Tutorial
    // Set the collison mask categories
    let rocketCategory: UInt32 = 0x1 << 0
    let floorCategory: UInt32 = 0x1 << 1
    let nothingCategory: UInt32 = 0x1 << 2
    let balloonCategory: UInt32 = 0x1 << 3
    
    // The dynamic labels in the Game Scene
    let scoreLabel = SKLabelNode(fontNamed:"Helvetica")
    let livesLabel = SKLabelNode(fontNamed:"Helvetica")
    let timerLabel = SKLabelNode(fontNamed:"Helvetica")
    //let launch = SKLabelNode(fontNamed:"Helvetica")
    
    // Load the game state model
    var gameState: GameState?
    var emitters: EmitterPaths?
    var timer: Timer?
    var TimeObserver: NSObjectProtocol?
    
    var numberOfRockets = 0
    var rocketsWithTrails: [Int] = []
    
    var rocketStats = RocketCounts()
    
    // Set the sprite sizes for the rockets
    var rocketSize = CGSize(width: 50, height: 80)
    
    
    override func sceneDidLoad() {
        
        // Rocket size scaling calculation
        // w is set to 7% of the width+height
        let w = (self.size.width + self.size.height) * 0.07
        rocketSize = CGSize(width: (w/2), height: w)
        
        // Initialise Game State
        gameState = GameState()
        emitters = EmitterPaths()
        
        startObservers()

        self.lastUpdateTime = 0
        
        // Add score text
        scoreLabel.text = "00000"
        scoreLabel.name = "score"
        scoreLabel.fontSize = 30
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x:self.frame.minX+100, y: self.frame.maxY-100)
        self.addChild(scoreLabel)
        
        
        print("Added score label")
        
        // Add lives text
        livesLabel.text = "5"
        livesLabel.name = "lives"
        livesLabel.fontSize = 30
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.fontColor = UIColor.yellow
        livesLabel.position = CGPoint(x:self.frame.maxX-100, y: self.frame.maxY-100)
        self.addChild(livesLabel)
        
        print("Added lives label")
        
        // Add lives text
        timerLabel.text = "1.5"
        timerLabel.name = "timer"
        timerLabel.fontSize = 30
        timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        timerLabel.fontColor = UIColor.yellow
        timerLabel.position = CGPoint(x:self.frame.maxX-100, y: self.frame.maxY-140)
        self.addChild(timerLabel)
        
        print("Added timer label")
        
        // Add debug launch button
//        launch.text = "Tap to begin";
//        launch.name = "launch"
//        launch.fontSize = 30;
//        launch.fontColor = UIColor.white
//        launch.position = CGPoint(x:self.frame.midX, y: self.frame.midY);
//        self.addChild(launch)
        
        print("Added launch button")
        
        // Set up the bottom of screen colision
        let bottomLeft = CGPoint(x: self.frame.minX, y: self.frame.minY)
        let bottomRight = CGPoint(x: self.frame.maxX, y: self.frame.minY)
        let bottomEdge = SKPhysicsBody(edgeFrom: bottomLeft, to: bottomRight)
        bottomEdge.categoryBitMask = floorCategory
        bottomEdge.contactTestBitMask = rocketCategory
        bottomEdge.collisionBitMask = 0
        self.physicsBody = bottomEdge
        
        // Set the scene
        backgroundColor = UIColor.black
        
        // Set up the gravity to pull the fireworks down
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -10)
        self.physicsWorld.contactDelegate = self
        
        
        print("Setup complete")
        
        activateStartTimer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        print("i touched something")
        
        for touch in touches {
            
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
//            if node.name == "launch"{
////                launch.isHidden = true
////                launch.removeFromParent()
//                activateTimer()
//                print("I have pressed the launch button!")
//            }
            

            // A rocket has been tapped to explode
            // As a named node has been tapped, safe to assume it is a rocket
            if let nameN = node.name {
                
                // First check for balloon
                if nameN.contains("life"){
                    gameState!.lives += 1
                    rocketStats.heart += 1
                    playNewLife()
                    node.removeFromParent()
                    return
                }
                
                
                let center = NotificationCenter.default
                let notification = Notification(name: Notification.Name(rawValue: "fireworkTouched"), object: self)
                
                // What is going on? checking if it has prefix color?
                // Really need to just check if node has R in name. Then extract the color and the value
                
                // Check if it is a Rocket for sure
                if nameN.contains("R") {
                    // Now extract the rocket colour and its ID
                    var splitName = nameN.split(separator: "R")
                    let rocketColour = (String)(splitName[0])
                    let rocketNumber = splitName[1]
                    
                    // Find the corresponding trail name
                    let trailName = "trail\(rocketNumber)"
                    
                    // Create the explosion and remove the trail
                    exploded(node, color: rocketColour)
                    if let trail = self.childNode(withName: trailName){
                        trail.removeFromParent()
                    }
                    
                    if (rocketColour == "skull"){
                        lostALife()
                        rocketStats.skull += 1
                    }
                    else if (rocketColour == "time"){
                        timeRocketHit()
                        rocketStats.time += 1
                    }
                    else {
                        switch(rocketColour){
                        case "red":
                            rocketStats.red += 1
                            break
                        case "orange":
                            rocketStats.orange += 1
                            break
                        case "yellow":
                            rocketStats.yellow += 1
                            break
                        case "green":
                            rocketStats.green += 1
                            break
                        case "blue":
                            rocketStats.blue += 1
                            break
                        case "purple":
                            rocketStats.purple += 1
                            break
                        case "pink":
                            rocketStats.pink += 1
                            break
                        default:
                            break
                        }
         
                        center.post(notification)
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func touchDown(atPoint pos : CGPoint) {}
    
    func touchMoved(toPoint pos : CGPoint) {}
    
    func touchUp(atPoint pos : CGPoint) {}
    
    ///////////////////////////////////// Collisions ///////////////////////////////////////////////
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let a = contact.bodyA // This will be the floor
        let b = contact.bodyB // This will be the rocket
        if let A = a.node!.name {
            assertionFailure("Non- floor collison, a is \(A)")
        }
        
        let direction = contact.contactNormal.dy
        
        // Direction 1.0 means straight down, as apposed to the -1.0 when rocket launches
        // So this is where a rocket falls out of the screen - a 'miss'
        if direction == 1.0 {
            b.node!.removeFromParent()
            if b.node!.name!.contains("skull"){}
            else if b.node!.name!.contains("time"){}
            else if b.node!.name!.contains("life"){}
            else {
                lostALife()
            }
        }
    }
    
    func lostALife() {
        gameState!.lives -= 1
        playOhNo()
        if gameState!.lives < 1 {
            endTheGame()
        }
    }
    
    func timeRocketHit(){
        // Add a percentage of time back to the interval
        let HEAL_ROCKET_PERCENTAGE = 0.15
        playSlowTime()
        gameState!.intervalTime += (gameState!.intervalTime * HEAL_ROCKET_PERCENTAGE)
    }
    
    ///////////////////////////// Observering and Timing ///////////////////////////////////////////////
    func startObservers() {
        let center = NotificationCenter.default
        //let uiQueue = OperationQueue.main // Doesn't do anything?
        center.addObserver(self, selector: #selector(GameScene.addToScore), name: NSNotification.Name(rawValue: "fireworkTouched"), object: nil)
    }
    
    func activateTimer() {
        assert(timer == nil && gameState != nil)
        // Want the timer to be a random length ±50% of the current intervaltime
        let VARIABILITY = 30
        
        let rand_positive = Int(arc4random_uniform(UInt32(VARIABILITY*2)))
        let rand_around_zero = rand_positive - VARIABILITY
        let percentageChange: Double = (Double)(rand_around_zero) / 100.0
        //let percentageChange = (Double)(arc4random_uniform(100) - 50) / 100.0 // Value between -0.50 and 0.50
        print("PercentageChange = \(percentageChange)")
        let randomTimeInterval = gameState!.intervalTime + (gameState!.intervalTime * percentageChange)
        print("RandomTimer = \(randomTimeInterval)")
        timer = Timer.scheduledTimer(timeInterval: randomTimeInterval, target: self,
                                     selector: #selector(GameScene.handleTimer), userInfo: nil, repeats: true)
    }
    
    func activateStartTimer() {
        assert(timer == nil && gameState != nil)
        timer = Timer.scheduledTimer(timeInterval: 3, target: self,
                                     selector: #selector(GameScene.handleTimer), userInfo: nil, repeats: true)
    }
    
    func cancelTimer() {
        assert(timer != nil)
        timer!.invalidate()
        timer = nil
    }
    
    
    // Game logic
    @objc func handleTimer() {
        
        let MINIMUM_INTERVAL = 0.40
        let PERCENTAGE_DECREASE = 0.01
        let PHASE_BOUNDARY = 1000
        
        // Decrease the interval time between rockets with each rocket (they speed up)
        if gameState!.intervalTime > MINIMUM_INTERVAL{
            // By reducing average interval time by a percentage, it will decrease faster at the start and then slow down
            gameState!.intervalTime = gameState!.intervalTime - (PERCENTAGE_DECREASE*gameState!.intervalTime)
        }
        
        // Every 5000 score, increment the 'phase'
        if gameState!.score / gameState!.phase > PHASE_BOUNDARY {
            gameState!.phase += 1
            //gameState!.intervalTime = 1.5
        }
        
        setUpNewRocket()
        
        if timer != nil && timer!.timeInterval != gameState!.intervalTime  {
            cancelTimer()
        }
        if timer == nil {
            activateTimer()
        }
        
    }
    
    ///////////////////////////////// Actions ////////////////////////////////////////
    
    func endTheGame() {
        cancelTimer()
        // Clean up the scene
        self.removeAllChildren()
        
        // Update the stats
        LocalSaveData.updateRocketCount(new: rocketStats)
        
        // Post the game over notification and attach the score
        let center = NotificationCenter.default
        let notification = Notification(
            name: Notification.Name(rawValue: "goToGameOver"), object: self, userInfo:["score":gameState?.score ?? 0])
        center.post(notification)
    }
    
    @objc func addToScore() {
        gameState!.score += 100
    }
    
    func exploded(_ node: SKNode, color: String){
        let explosion: SKEmitterNode
        
        //http://stackoverflow.com/questions/24083938/adding-a-particle-emitter-to-the-flappyswift-project
        //http://goobbe.com/questions/4782463/adding-emitter-node-to-sks-file-and-using-it-xcode-6-0-swift
        // Load the correct explosion SKEmitterNode
        explosion = NSKeyedUnarchiver.unarchiveObject(withFile: emitters!.emitterPathDictionary[color]!) as! SKEmitterNode
        
        
        // Add the explosion emitter
        let deathLoc = node.position
        node.removeFromParent()
        explosion.position = deathLoc
        self.addChild(explosion)
        playExplode()
        explosion.zPosition = CGFloat(-1)
        explosion.particleZPosition = CGFloat(-1)
        explosion.run(explode)
    }
    
    
    // Called before each frame is rendered
    // Important to optimise - version 0.1 started to lag with 5+ rockets at once
    // Changed the loop to cover just active trails
    override func update(_ currentTime: TimeInterval) {
        
        let equiv_speed = (Int)(100.0 / gameState!.intervalTime)
        
        scoreLabel.text = "\(gameState!.score) 💥"
        livesLabel.text = "\(gameState!.lives) ❤️"
        timerLabel.text = "\(equiv_speed) 💨"
        
        // Update the position of the flame trails and flip the sprites if necessary
        //for i in 0...numberOfRockets {
        for i in rocketsWithTrails {
            // Search through the flame trails
            if let trl = self.childNode(withName: "trail\(i)"){
                // Identify the name of the rocket that it is 'attached' to
                var rocket: SKNode = SKNode()
                if let red = self.childNode(withName: "redR\(i)"){ rocket = red }
                else if let yel = self.childNode(withName: "yellowR\(i)"){ rocket = yel }
                else if let blu = self.childNode(withName: "blueR\(i)"){ rocket = blu }
                else if let grn = self.childNode(withName: "greenR\(i)"){ rocket = grn }
                else if let pink = self.childNode(withName: "pinkR\(i)"){ rocket = pink }
                else if let prp = self.childNode(withName: "purpleR\(i)"){ rocket = prp }
                else if let ora = self.childNode(withName: "orangeR\(i)"){ rocket = ora }
                else if let skull = self.childNode(withName: "skullR\(i)"){ rocket = skull }
                else if let time = self.childNode(withName: "timeR\(i)"){ rocket = time }
                else {
                    print("A rocket trail had no rocket!")
                    trl.removeFromParent()
                    return
                }
                
                // Either move the trail up or remove it if the rocket is on its descent
                let up = rocket.physicsBody!.velocity.dy >= 0
                let pos = rocket.position
                if up {
                    trl.position = CGPoint(x: pos.x, y:pos.y)
                }
                else {
                    trl.removeFromParent()
                    // Remove the trail number from the working array
                    rocketsWithTrails = rocketsWithTrails.filter{ $0 != i}
                    rocket.yScale = -1
                }
            }
        }
    }
                
    // Decide what kind of rocket to fire
    func setUpNewRocket() {
        
        let SPECIAL_PHASE = 2 // Phase where specials begin
        let SKULL_CHANCE = min(1 * gameState!.phase, 30)
        let TIME_CHANCE = 2
        let LIFE_CHANCE = 1
        
        
        if (gameState!.phase >= SPECIAL_PHASE) {
            let skull_roll = Int(arc4random_uniform(100))
            if skull_roll < (SKULL_CHANCE){
                fireRocket("skull")
            }
            else {
                launchRegularRocket()
            }
            
            let time_roll = Int(arc4random_uniform(100))
            if time_roll < TIME_CHANCE {
                fireRocket("time")
            }
            let life_roll = Int(arc4random_uniform(100))
            if life_roll < LIFE_CHANCE {
                // Release life balloon
                dropLifeBalloon()
            }
        }
        else {
            launchRegularRocket()
        }
        
    }
    
    func launchRegularRocket() {
        // http://stackoverflow.com/questions/24007129/how-does-one-generate-a-random-number-in-apples-swift-language
        let roll = Int(arc4random_uniform(7))
        
        switch roll{
        case 0:
            fireRocket("red")
        case 1:
            fireRocket("orange")
        case 2:
            fireRocket("yellow")
        case 3:
            fireRocket("green")
        case 4:
            fireRocket("blue")
        case 5:
            fireRocket("purple")
        case 6:
            fireRocket("pink")
        default:
            assertionFailure("Invalid rocket number was rolled")
        }
    }
    
    
    func fireRocket(_ color: String) {
        let rocket: SKSpriteNode
        let trail: SKEmitterNode
        
        // Initialise the rocket, depending on the color
        
        // Special Rocket is skull or time
        
        let rktName: String = "\(color)Rocket"
        let RName: String = "\(color)R"
        rocket = SKSpriteNode(imageNamed: rktName)
        
        // Small rockets
        if ["time"].contains(color) {
            rocket.size = CGSize(width: rocketSize.width, height: rocketSize.height * 0.50)
        }
        // Wide rockets
        else if ["skull"].contains(color) {
            rocket.size = CGSize(width: 2*rocketSize.width, height: rocketSize.height)
        }
        // Regular rockets
        else {
            rocket.size = rocketSize
        }
        rocket.name = "\(RName)\(numberOfRockets)"
        
        // Initialise the flame trail
        trail = NSKeyedUnarchiver.unarchiveObject(withFile: emitters!.emitterPathDictionary["trail"]!) as! SKEmitterNode
        trail.name = "trail\(numberOfRockets)"
        
        // Decide where to randomly launch the rocket from
        let leftX = Int(self.frame.minX) + 100
        let rightX = Int(self.frame.maxX) - 100
        let Xdistance = rightX - leftX
        let Xposition = leftX + Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(self.frame.minY)
        rocket.position = CGPoint(x: Xposition, y: Yposition)
        trail.position = CGPoint(x: rocket.position.x + 25, y:rocket.position.y)
        trail.zPosition = CGFloat(-2)
        trail.particleZPosition = CGFloat(-2)
        
        // Add the trail to active set
        rocketsWithTrails.append(numberOfRockets)
        
        // Set up the physics body for the rocket
        rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size)
        rocket.physicsBody!.isDynamic = true
        rocket.physicsBody!.mass = CGFloat(0.01)
        rocket.physicsBody!.categoryBitMask = rocketCategory
        rocket.physicsBody!.contactTestBitMask = floorCategory
        rocket.physicsBody!.collisionBitMask = 0
        numberOfRockets += 1
        
        // Add the rocket and apply a random vertical force to it
        self.addChild(rocket)
        self.addChild(trail)
        // 157 is the point to metre ratio
        //http://stackoverflow.com/questions/29676701/suvat-maths-dont-add-up-in-spritekits-physics-engine-ios-objective-c
        let frameHeight = (self.frame.height - 50)*157
        // using u^2 = -2gs
        let maxVel = Double(round(sqrt(frameHeight*20)))
        let initialVel = Int(round(maxVel*0.8))
        let randomVel = Int(maxVel) - initialVel
        //println("Frame: \(frameHeight), Velocity = \(initialVel) + \(randomVel)")
        let velocity = CGFloat(initialVel + Int(arc4random_uniform(UInt32(randomVel))))
        //println("Rocket \(rocket.name) of mass \(rocket.physicsBody!.mass) launched with velocity \(velocity)")
        rocket.physicsBody!.velocity.dy = velocity
        playLaunch()
    }
    
    func dropLifeBalloon(){
        let balloon: SKSpriteNode
        
        // Initialise the balloon
        
        let BName: String = "lifeB"
        balloon = SKSpriteNode(imageNamed: "heartBalloon")
        
        balloon.size = CGSize(width: rocketSize.width, height: rocketSize.height * 0.50)
        
        balloon.name = "\(BName)\(numberOfRockets)"
        
        // Decide where to randomly launch the rocket from
        let leftX = Int(self.frame.minX) + 100
        let rightX = Int(self.frame.maxX) - 100
        let Xdistance = rightX - leftX
        let Xposition = leftX + Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(self.frame.maxY)
        balloon.position = CGPoint(x: Xposition, y: Yposition)
        
        
        let fall = SKAction.moveTo(y: self.frame.minY - 100, duration: 2)
        let dropBalloon = SKAction.sequence([fall, death])
        balloon.run(dropBalloon)

        numberOfRockets += 1
        
        // Add the rocket and apply a random vertical force to it
        self.addChild(balloon)
        //println("Rocket \(rocket.name) of mass \(rocket.physicsBody!.mass) launched with velocity \(velocity)")
//        balloon.physicsBody!.velocity.dy = 0.0
        
        //playLaunch()
    }
    
    
    
    /////////// Play sounds ////////////////
    
    func playExplode(){
        let bangNum = Int(arc4random_uniform(5))
        let bangFile = "bang-\(bangNum+1).wav"
        run(SKAction.playSoundFileNamed(bangFile, waitForCompletion: false))
    }
    
    func playLaunch(){
        let pewNum = Int(arc4random_uniform(6))
        let pewFile = "pew-\(pewNum+1).wav"
        run(SKAction.playSoundFileNamed(pewFile, waitForCompletion: false))
    }
    
    func playOhNo(){
        let ohnoFile = "ohno-1.wav"
        run(SKAction.playSoundFileNamed(ohnoFile, waitForCompletion: false))
    }
    
    func playNewLife(){
        let lifeFile = "life.wav"
        run(SKAction.playSoundFileNamed(lifeFile, waitForCompletion: false))
    }
    func playSlowTime(){
        let slowFile = "slow.wav"
        run(SKAction.playSoundFileNamed(slowFile, waitForCompletion: false))
    }
}
