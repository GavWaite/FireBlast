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
    
    @IBOutlet weak var localHighscoreLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var saveScoreButton: UIButton!
    
    
    // Code to be run when arrived at the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Attempt to authenticate the user for GameCenter
        authenticateUser()
        
        // Set up any programmatic text or elements for the Game Over Screen here
        scoreLabel.text = "\(latestScore)"
        
        // Hide the localHighscoreLabel for now and button is shown
        localHighscoreLabel.isHidden = true
        saveScoreButton.isHidden = false
        
        // Update the saved stats and display in labels
        UpdateStats()
        
        // Attempt to post the latest score to GameCenter
        tryPostScore()
        
    }
    
    func UpdateStats(){
        
        // Update the local stats
        LocalSaveData.addNewScore(score: latestScore)
        
//        let games = LocalSaveData.getGamesPlayed()
//        let avg = LocalSaveData.getAverageScore()
//        
//        gamesPlayedLabel.text = "Games Played: \(games)"
//        averageScoreLabel.text = "Average Score: \(avg)"
        
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
    
    @IBAction func saveLocalScore() {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Player name", message: "Enter your name for the leaderboard", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
            textField.autocapitalizationType = .words
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let playerName: String = alert?.textFields![0].text {
                
                var scores = LocalSaveData.loadLocalHighscores()
                
                // Does the player exist?
                if let existingScore = scores[playerName]{
                    print("Player \(playerName) found")
                    
                    // Player exists, is it a new highscore?
                    if self.latestScore > (Int)(existingScore)! {
                        print("New highscore of \(self.latestScore) beats \(existingScore) for \(playerName)")
                        scores[playerName] = "\(self.latestScore)"
                        LocalSaveData.saveLocalHighscores(scores: scores)
                        
                        self.localHighscoreLabel.isHidden = false
                        self.localHighscoreLabel.text = "\(playerName) - New Highscore!"
                        self.saveScoreButton.isHidden = true
                        
                    }
                    else {
                        print("New score of \(self.latestScore) not better than \(existingScore) for \(playerName)")
                        
                        self.localHighscoreLabel.isHidden = false
                        self.localHighscoreLabel.text = "\(playerName) - Highscore is \(existingScore)"
                        self.saveScoreButton.isHidden = true
                    }
                    
                }
                else {
                    print("New player \(playerName)")
                    scores["\(playerName)"] = "\(self.latestScore)"
                    LocalSaveData.saveLocalHighscores(scores: scores)
                    
                    self.localHighscoreLabel.isHidden = false
                    self.localHighscoreLabel.text = "\(playerName) - New Player!"
                    self.saveScoreButton.isHidden = true
                }
            }
            else {
                print("No name entered")
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
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
