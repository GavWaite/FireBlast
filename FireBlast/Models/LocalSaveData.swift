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

struct LocalSaveData {
    
    static func firstTimeCheck(){
        let defaults = UserDefaults.standard
        
        if defaults.value(forKey: firstTimeKey) == nil {
            defaults.setValue(true, forKey: firstTimeKey)
            defaults.setValue([:], forKey: localHighscoresKey)
            defaults.setValue(0, forKey: gamesPlayedKey)
            defaults.setValue(0, forKey: averageScoreKey)
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
    
}
