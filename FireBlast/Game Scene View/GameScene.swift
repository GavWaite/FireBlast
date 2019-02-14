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

// Convenience Constants

// SKAction shortcuts
let fire = SKAction.moveTo(y: 20, duration: 2)
let death = SKAction.removeFromParent()
let wait = SKAction.wait(forDuration: 1)
let explode = SKAction.sequence([wait, death])

//http://stackoverflow.com/questions/24043904/creating-and-playing-a-sound-in-swift
// File paths and Sound IDs for the sound effects
let explosionPath = Bundle.main.path(forResource: "75328__oddworld__oddworld-explosionecho", ofType: "wav")
let explosionURL = URL(fileURLWithPath: explosionPath!)
var explosionID: SystemSoundID = 0

let launchPath = Bundle.main.path(forResource: "202230__deraj__pop-sound", ofType: "wav")
let launchURL = URL(fileURLWithPath: launchPath!)
var launchID: SystemSoundID = 1



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
    
    // The dynamic labels in the Game Scene
    let scoreLabel = SKLabelNode(fontNamed:"Helvetica")
    let livesLabel = SKLabelNode(fontNamed:"Helvetica")
    let launch = SKLabelNode(fontNamed:"Helvetica")
    
    // Load the game state model
    var gameState: GameState?
    var emitters: EmitterPaths?
    var timer: Timer?
    var TimeObserver: NSObjectProtocol?
    
    var numberOfRockets = 0
    
    // Set the sprite sizes for the rockets
    var rocketSize = CGSize(width: 50, height: 80)
    
    
    override func sceneDidLoad() {
        
        // DEBUG
        if let redString = Bundle.main.path(forResource: "RedFireworksSparks", ofType: "sks"){
            print("Red String path is \(redString)")
        }
        else {
            print("Could nae find it")
        }
        
        // Rocket size scaling calculation
        // w is set to 5% of the width+height
        let w = (self.size.width + self.size.height) * 0.05
        rocketSize = CGSize(width: w, height: w)
        
        // Initialise Game State
        gameState = GameState()
        emitters = EmitterPaths()
        
        startObservers()
        AudioServicesCreateSystemSoundID(explosionURL as CFURL, &explosionID)
        AudioServicesCreateSystemSoundID(launchURL as CFURL, &launchID)
        
        self.lastUpdateTime = 0
        
        // Add score text
        scoreLabel.text = "00000"
        scoreLabel.name = "score"
        scoreLabel.fontSize = 30
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x:self.frame.minX+100, y: self.frame.maxY-100)
        self.addChild(scoreLabel)
        
        
        print("Added score")
        
        // Add lives text
        livesLabel.text = "5"
        livesLabel.name = "lives"
        livesLabel.fontSize = 30
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.fontColor = UIColor.yellow
        livesLabel.position = CGPoint(x:self.frame.maxX-100, y: self.frame.maxY-100)
        self.addChild(livesLabel)
        
        print("Added lives")
        
        // Add debug launch button
        launch.text = "Tap to begin";
        launch.name = "launch"
        launch.fontSize = 30;
        launch.fontColor = UIColor.white
        launch.position = CGPoint(x:self.frame.midX, y: self.frame.midY);
        self.addChild(launch)
        
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
    }
    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        print("i touched something")
        
        for touch in touches {
            
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == "launch"{
                launch.isHidden = true
                launch.removeFromParent()
                activateTimer()
                print("I have pressed the launch button!")
            }
            
            // A rocket has been tapped to explode
            if let nameN = node.name {
                let center = NotificationCenter.default
                let notification = Notification(name: Notification.Name(rawValue: "fireworkTouched"), object: self)
                if nameN.hasPrefix("redR"){
                    exploded(node, color: "red")
                    let rktNum = (nameN as NSString).substring(from: 4)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("orangeR"){
                    exploded(node, color: "orange")
                    let rktNum = (nameN as NSString).substring(from: 7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("yellowR"){
                    exploded(node, color: "yellow")
                    let rktNum = (nameN as NSString).substring(from: 7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("greenR"){
                    exploded(node, color: "green")
                    let rktNum = (nameN as NSString).substring(from: 6)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("blueR"){
                    exploded(node, color: "blue")
                    let rktNum = (nameN as NSString).substring(from: 5)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("purpleR"){
                    exploded(node, color: "purple")
                    let rktNum = (nameN as NSString).substring(from: 7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("pinkR"){
                    exploded(node, color: "pink")
                    let rktNum = (nameN as NSString).substring(from: 5)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
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
    
    ///////////////////////////////////// Collisions ///////////////////////////////////////////////
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let a = contact.bodyA // This will be the floor
        let b = contact.bodyB // This will be the rocket
        if let A = a.node!.name {
            assertionFailure("Non- floor collison, a is \(A)")
        }
        
        let direction = contact.contactNormal.dy
        
        if direction == 1.0 { // Direction 1.0 means straight down, as apposed to the -1.0 when rocket launches
            b.node!.removeFromParent()
            gameState!.lives -= 1
            if gameState!.lives < 1 {
                endTheGame()
            }
        }
    }
    
    ///////////////////////////// Observering and Timing ///////////////////////////////////////////////
    func startObservers() {
        let center = NotificationCenter.default
        //let uiQueue = OperationQueue.main
        center.addObserver(self, selector: #selector(GameScene.addToScore), name: NSNotification.Name(rawValue: "fireworkTouched"), object: nil)
    }
    
    func activateTimer() {
        assert(timer == nil && gameState != nil)
        timer = Timer.scheduledTimer(timeInterval: gameState!.intervalTime, target: self,
                                     selector: #selector(GameScene.handleTimer), userInfo: nil, repeats: true)
    }
    
    func cancelTimer() {
        assert(timer != nil)
        timer!.invalidate()
        timer = nil
    }
    
    @objc func handleTimer() {
        if gameState!.intervalTime > 0.5{
            gameState!.intervalTime = gameState!.intervalTime - 0.02
        }
        
        if gameState!.score / gameState!.phase > 5000 {
            gameState!.phase += 1
            gameState!.intervalTime = 1.5
        }
        
        for _ in 1...gameState!.phase {
            setUpNewRocket()
        }
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
        //scores!.tempScore = model!.score
        self.removeAllChildren()
        let center = NotificationCenter.default
        let notification = Notification(
            name: Notification.Name(rawValue: "goToGameOver"), object: self)
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scoreLabel.text = "\(gameState!.score)"
        livesLabel.text = "\(gameState!.lives) ❤️"
        
        
        // Update the position of the flame trails and flip the sprites if necessary
        for i in 0...numberOfRockets {
            if let trl = self.childNode(withName: "trail\(i)"){
                if let red = self.childNode(withName: "redR\(i)"){
                    let up = red.physicsBody!.velocity.dy >= 0
                    let pos = red.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        red.yScale = -1
                    }
                }
                else if let yel = self.childNode(withName: "yellowR\(i)"){
                    let up = yel.physicsBody!.velocity.dy >= 0
                    let pos = yel.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        yel.yScale = -1
                    }
                }
                else if let ora = self.childNode(withName: "orangeR\(i)"){
                    let up = ora.physicsBody!.velocity.dy >= 0
                    let pos = ora.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        ora.yScale = -1
                    }
                }
                else if let grn = self.childNode(withName: "greenR\(i)"){
                    let up = grn.physicsBody!.velocity.dy >= 0
                    let pos = grn.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        grn.yScale = -1
                    }
                }
                else if let blu = self.childNode(withName: "blueR\(i)"){
                    let up = blu.physicsBody!.velocity.dy >= 0
                    let pos = blu.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        blu.yScale = -1
                    }
                }
                else if let pur = self.childNode(withName: "purpleR\(i)"){
                    let up = pur.physicsBody!.velocity.dy >= 0
                    let pos = pur.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        pur.yScale = -1
                    }
                }
                else if let pin = self.childNode(withName: "pinkR\(i)"){
                    let up = pin.physicsBody!.velocity.dy >= 0
                    let pos = pin.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        pin.yScale = -1
                    }
                }
            }
        }
    }
    
    // Decide what kind of rocket to fire
    func setUpNewRocket() {
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
        let rktName: String = "\(color)Rocket"
        let RName: String = "\(color)R"
        rocket = SKSpriteNode(imageNamed: rktName)
        rocket.size = rocketSize
        rocket.name = "\(RName)\(numberOfRockets)"
        
        // Initialise the flame trail
        trail = NSKeyedUnarchiver.unarchiveObject(withFile: emitters!.emitterPathDictionary["trail"]!) as! SKEmitterNode
        trail.name = "trail\(numberOfRockets)"
        
        // Decide where to randomly launch the rocket from
        let leftX = Int(self.frame.minX) + 30
        let rightX = Int(self.frame.maxX) - 30
        let Xdistance = rightX - leftX
        let Xposition = leftX + Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(self.frame.minY)
        rocket.position = CGPoint(x: Xposition, y: Yposition)
        trail.position = CGPoint(x: rocket.position.x + 25, y:rocket.position.y)
        trail.zPosition = CGFloat(-2)
        trail.particleZPosition = CGFloat(-2)
        
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
    
    /////////// Play sounds ////////////////
    
    func playExplode(){
        //if !settings!.mutedSound {
            AudioServicesPlaySystemSound(explosionID)
        //}
    }
    
    func playLaunch(){
        //if !settings!.mutedSound {
            AudioServicesPlaySystemSound(launchID)
        //}
    }
}
