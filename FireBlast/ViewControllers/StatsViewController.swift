//
//  SettingsViewController.swift
//  FireBlast
//
//  Created by Gavin Waite on 13/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import Foundation
import UIKit

class StatsViewController : UIViewController {
    
    // Overall Stats
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var averageScoreLabel: UILabel!
    
    // Regular Rockets
    @IBOutlet weak var redRocketsLabel: UILabel!
    @IBOutlet weak var orangeRocketsLabel: UILabel!
    @IBOutlet weak var yellowRocketsLabel: UILabel!
    @IBOutlet weak var greenRocketsLabel: UILabel!
    @IBOutlet weak var blueRocketsLabel: UILabel!
    @IBOutlet weak var purpleRocketsLabel: UILabel!
    @IBOutlet weak var pinkRocketsLabel: UILabel!
    @IBOutlet weak var totalRocketsLabel: UILabel!
    
    // Specials
    @IBOutlet weak var heartBalloonsLabel: UILabel!
    @IBOutlet weak var skullRocketsLabel: UILabel!
    @IBOutlet weak var timeRocketsLabel: UILabel!
    

    
    // Code to be run when arrived at the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    func updateLabels() {
        let g = LocalSaveData.getGamesPlayed()
        let av = LocalSaveData.getAverageScore()
        let r: RocketCounts = LocalSaveData.returnRocketCounts()

        gamesPlayedLabel.text = "\(g)"
        averageScoreLabel.text = "\(av)"
        
        redRocketsLabel.text = "\(r.red)"
        orangeRocketsLabel.text = "\(r.orange)"
        yellowRocketsLabel.text = "\(r.yellow)"
        greenRocketsLabel.text = "\(r.green)"
        blueRocketsLabel.text = "\(r.blue)"
        purpleRocketsLabel.text = "\(r.purple)"
        pinkRocketsLabel.text = "\(r.pink)"
        totalRocketsLabel.text = "\(r.red + r.orange + r.yellow + r.green + r.blue + r.purple + r.pink)"

        heartBalloonsLabel.text = "\(r.heart)"
        skullRocketsLabel.text = "\(r.skull)"
        timeRocketsLabel.text = "\(r.time)"
    }
    
    @IBAction func resetButtonPressed() {
        LocalSaveData.resetAllStatistics()
        updateLabels()
    }
    
    // Ideas for settings
    // - Volume
    // - Mute all sounds
    
    // Maybe some dev gameplay tuning settings for the DEBUG release
    // - FPS / Node counter
    // - Firework speed
    // - Firework count
    // - Cutoff values
    // - Round wait time etc.
    
}
