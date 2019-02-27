//
//  EmitterPaths.swift
//  FireBlast
//
//  Created by Gavin Waite on 14/02/2019.
//  Copyright © 2019 GavinWaite. All rights reserved.
//

import Foundation

class EmitterPaths {
    
    // Dictionary of color string to path string
    var emitterPathDictionary: [String : String] = [
        "red" : Bundle.main.path(forResource: "RedFireworksSparks", ofType: "sks")!,
        "yellow" : Bundle.main.path(forResource: "YellowFireworksSparks", ofType: "sks")!,
        "green" : Bundle.main.path(forResource: "GreenFireworksSparks", ofType: "sks")!,
        "pink" : Bundle.main.path(forResource: "PinkFireworksSparks", ofType: "sks")!,
        "purple" : Bundle.main.path(forResource: "PurpleFireworksSparks", ofType: "sks")!,
        "orange" : Bundle.main.path(forResource: "OrangeFireworksSparks", ofType: "sks")!,
        "blue" : Bundle.main.path(forResource: "BlueFireworksSparks", ofType: "sks")!,
        "skull" : Bundle.main.path(forResource: "BombRocketEffect", ofType: "sks")!,
        "time" : Bundle.main.path(forResource: "TimeRocketEffect", ofType: "sks")!,
        "trail" : Bundle.main.path(forResource: "flameTrail", ofType: "sks")!
    ]
}
