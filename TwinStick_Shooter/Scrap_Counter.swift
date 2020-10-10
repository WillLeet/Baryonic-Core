//
//  Scrap_Counter.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 10/6/20.
//  Copyright © 2020 William Leet. All rights reserved.
//


import UIKit
import SpriteKit
import GameplayKit

class Scrap_Counter: ObservableObject{
    
    @Published var display: String
    var total: Int = 0
    
    init(){
        display = String(total)
    }
    
    func increment(val: Int) -> String{
        total += val
        display = String(total)
        return display
    }
    
}
