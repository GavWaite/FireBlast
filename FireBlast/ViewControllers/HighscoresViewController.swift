//
//  HighscoresViewController.swift
//  FireBlast
//
//  Created by Gavin Waite on 13/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import Foundation
import UIKit

struct Identifiers {
    static let basicCell = "scoreCell"
}

class HighscoresViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var highscoresTable: UITableView!
    
    var highScoreData: [String:String] = [:]
    var sortedScores: [(key: String, value: String)] = []
    
    // Code to be run when arrived at the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up any programmatic text or elements for the High score screen here
        highscoresTable.dataSource = self
        highscoresTable.delegate = self
        
        highScoreData = LocalSaveData.loadLocalHighscores()
        
        sortedScores = highScoreData.sorted(by: { (Int)($0.value)! > (Int)($1.value)! })
        
        
        
    }
    
    // Need a table view for the Highscores
    /////// Set up table view /////////
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedScores.count
    }
    
    ////////// Fill table view ///////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.basicCell, for: indexPath) as! LocalHighScoreCell
        cell.nameLabel!.text = "\(indexPath.row + 1): \(sortedScores[indexPath.row].key)"
        cell.scoreLabel!.text = "\(sortedScores[indexPath.row].value)"
        return cell
    }
    
    
}
