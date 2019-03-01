//
//  MainMenuViewController.swift
//  FireBlast
//
//  Created by Gavin Waite on 13/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import Foundation
import UIKit

class MainMenuViewController : UIViewController {
    
    
    // Code to be run when arrived at the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up any programmatic text or elements for the MainMenu here
        
        // Perform the first time check for local saved data
        LocalSaveData.firstTimeCheck()
        
        // Ensure no null data
        LocalSaveData.nullCheck()
        
    }
    
    // Could I add a system to go to tutorial the first time you press Play?
    
}
