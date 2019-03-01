//
//  LocalSaveData.swift
//  FireBlast
//
//  Created by Gavin Waite on 16/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import Foundation

let firstTimeKey = "FIRST_TIME"
let localHighscoresKey = "LOCAL_HIGHSCORES"

let gamesPlayedKey = "GAMES_PLAYED"
let averageScoreKey = "AVERAGE_SCORE"

let redRocketsKey = "RED_ROCKETS"
let orangeRocketsKey = "ORANGE_ROCKETS"
let yellowRocketsKey = "YELLOW_ROCKETS"
let greenRocketsKey = "GREEN_ROCKETS"
let blueRocketsKey = "BLUE_ROCKETS"
let purpleRocketsKey = "PURPLE_ROCKETS"
let pinkRocketsKey = "PINK_ROCKETS"

let heartBalloonsKey = "HEART_BALLOONS"
let skullRocketsKey = "SKULL_ROCKETS"
let timeRocketsKey = "TIME_ROCKETS"

let zero_keys = [gamesPlayedKey, averageScoreKey, redRocketsKey,orangeRocketsKey,yellowRocketsKey,
greenRocketsKey,blueRocketsKey,purpleRocketsKey,pinkRocketsKey,heartBalloonsKey,skullRocketsKey,timeRocketsKey]

struct RocketCounts {
    var red: Int = 0
    var orange: Int = 0
    var yellow: Int = 0
    var green: Int = 0
    var blue: Int = 0
    var purple: Int = 0
    var pink: Int = 0
    var heart: Int = 0
    var skull: Int = 0
    var time: Int = 0
}


struct LocalSaveData {
    
    static func firstTimeCheck(){
        let defaults = UserDefaults.standard
        
        if defaults.value(forKey: firstTimeKey) == nil {
            resetAllStatistics()
            defaults.setValue(true, forKey: firstTimeKey)
        }
    }
    
    static func addNewScore(score: Int){
        let defaults = UserDefaults.standard
        
        let storedGamesPlayed = defaults.value(forKey: gamesPlayedKey) as! Int
        let storedAvgScore = defaults.value(forKey: averageScoreKey) as! Int
        
        let sumScore = storedGamesPlayed * storedAvgScore
        
        let newSum = sumScore + score
        let newGamesPlayed = storedGamesPlayed + 1
        let newAvg = (Int)(newSum / newGamesPlayed)
        
        defaults.setValue(newGamesPlayed, forKey: gamesPlayedKey)
        defaults.setValue(newAvg, forKey: averageScoreKey)
    }
    
    static func getGamesPlayed() -> Int {
        return UserDefaults.standard.value(forKey: gamesPlayedKey) as! Int
    }
    
    static func getAverageScore() -> Int {
        return UserDefaults.standard.value(forKey: averageScoreKey) as! Int
    }
    
    static func saveLocalHighscores(scores: [String:String]){
        let defaults = UserDefaults.standard
        defaults.setValue(scores, forKey: localHighscoresKey)
    }
    
    static func loadLocalHighscores() -> [String:String] {
        let defaults = UserDefaults.standard
        let scores = defaults.value(forKey: localHighscoresKey) as! [String:String]
        return scores
    }
    
    static func resetAllStatistics(){
        let defaults = UserDefaults.standard
        
        defaults.setValue([:], forKey: localHighscoresKey)
        defaults.setValue(0, forKey: gamesPlayedKey)
        defaults.setValue(0, forKey: averageScoreKey)
        
        defaults.setValue(0, forKey: redRocketsKey)
        defaults.setValue(0, forKey: orangeRocketsKey)
        defaults.setValue(0, forKey: yellowRocketsKey)
        defaults.setValue(0, forKey: greenRocketsKey)
        defaults.setValue(0, forKey: blueRocketsKey)
        defaults.setValue(0, forKey: purpleRocketsKey)
        defaults.setValue(0, forKey: pinkRocketsKey)
        
        defaults.setValue(0, forKey: heartBalloonsKey)
        defaults.setValue(0, forKey: skullRocketsKey)
        defaults.setValue(0, forKey: timeRocketsKey)
        
        print("Reset all Stats")
    }
    
    static func nullCheck() {
        let defaults = UserDefaults.standard
        
        // Iterate through all keys which should init as zero and make sure
        // that if they are null that they are reset to zero
        for key in zero_keys {
            if let _ = defaults.value(forKey: key){}
            else {
                defaults.setValue(0, forKey: key)
            }
        }
        
        
    }
    
    static func updateRocketCount(new: RocketCounts){
        let d = UserDefaults.standard
        
        let current: RocketCounts = returnRocketCounts()
        
        d.setValue(new.red + current.red, forKey: redRocketsKey)
        d.setValue(new.orange + current.orange, forKey: orangeRocketsKey)
        d.setValue(new.yellow + current.yellow, forKey: yellowRocketsKey)
        d.setValue(new.green + current.green, forKey: greenRocketsKey)
        d.setValue(new.blue + current.blue, forKey: blueRocketsKey)
        d.setValue(new.purple + current.purple, forKey: purpleRocketsKey)
        d.setValue(new.pink + current.pink, forKey: pinkRocketsKey)
        
        d.setValue(new.heart + current.heart, forKey: heartBalloonsKey)
        d.setValue(new.skull + current.skull, forKey: skullRocketsKey)
        d.setValue(new.time + current.time, forKey: timeRocketsKey)
        
        
    }
    
    static func returnRocketCounts() -> RocketCounts {
        let d = UserDefaults.standard
        
        var r: RocketCounts = RocketCounts()
        r.red = d.value(forKey: redRocketsKey) as! Int
        r.orange = d.value(forKey: orangeRocketsKey) as! Int
        r.yellow = d.value(forKey: yellowRocketsKey) as! Int
        r.green = d.value(forKey: greenRocketsKey) as! Int
        r.blue = d.value(forKey: blueRocketsKey) as! Int
        r.purple = d.value(forKey: purpleRocketsKey) as! Int
        r.pink = d.value(forKey: pinkRocketsKey) as! Int
        
        r.heart = d.value(forKey: heartBalloonsKey) as! Int
        r.skull = d.value(forKey: skullRocketsKey) as! Int
        r.time = d.value(forKey: timeRocketsKey) as! Int
        
        return r
    }
    
}
