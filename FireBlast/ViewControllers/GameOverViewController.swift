//
//  GameOverViewController.swift
//  FireBlast
//
//  Created by Gavin Waite on 13/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class GameOverViewController : UIViewController, GKGameCenterControllerDelegate{
    
    var latestScore = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    // Code to be run when arrived at the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        // Set up any programmatic text or elements for the Game Over Screen here
        scoreLabel.text = "\(latestScore)"
        
        tryPostScore()
        
    }
    
    // GAME CENTRE LEADERBOARDS
    // https://medium.com/@vladfedoseyev/lets-build-a-mobile-puzzle-game-from-scratch-part-iii-game-center-1bffd176f1b1
    var gcEnabled = false
    let leaderboardID = "fireBlastGlobalLeaderboard"
    
    func tryPostScore(){
        if gcEnabled {
            self.reportScore(score: Int64(latestScore))
        }
        else {
            print("GC is not authenticated")
        }
    }
    
    
    
    @IBAction func showLeaderboard() {
        
        tryPostScore()
        
        let vc = GKGameCenterViewController()
        
        vc.gameCenterDelegate = self
        vc.viewState = .leaderboards
        vc.leaderboardIdentifier = leaderboardID
        
        present(vc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func authenticateUser() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { (vc, error) -> Void in
            if vc != nil {
                //show game center sign in controller
                self.present(vc!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                //user has succesfully logged in
                self.gcEnabled = true
                self.tryPostScore()
            } else {
                //game center is disabled on the device
                self.gcEnabled = false
            }
        }
    }
    
    
    func reportScore(score: Int64) {
        //create a GKScore object
        let reportedScore = GKScore(leaderboardIdentifier: leaderboardID)
        reportedScore.value = score
        GKScore.report([reportedScore]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Score has been submitted to the game center")
            }
        }
    }
    
    
    
    
    
    
    // Add a method to save your name and highscore
    // Maybe list previous users?
    // If new highscore for that user then alert them
    
}
