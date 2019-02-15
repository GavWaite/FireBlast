//
//  GameViewController.swift
//  FireBlast
//
//  Created by Gavin Waite on 11/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var latestScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservers()
        gameState = GameState()
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {

            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {

                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs

                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill

                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)

                    view.ignoresSiblingOrder = true

                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    var gameOverObs: NSObjectProtocol?
    var gameState: GameState?
    //var scores: Highscores?

    override var shouldAutorotate: Bool {
        return true
    }
    
    // Start an observer to watch for GameOver to trigger the segue

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func startObservers() {
        let center = NotificationCenter.default
        let uiQueue = OperationQueue.main
        center.addObserver(self, selector: #selector(GameViewController.gameOver(notification:)), name: NSNotification.Name(rawValue: "goToGameOver"), object: nil)
    }
    
    // http://stackoverflow.com/questions/21578391/presenting-uiviewcontroller-from-skscene
    @objc func gameOver(notification:Notification) {
        latestScore = notification.userInfo?["score"] as! Int
        self.performSegue(withIdentifier: "gameOver", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameOverViewController
        {
            let vc = segue.destination as? GameOverViewController
            vc?.latestScore = latestScore
        }
    }
    
}
