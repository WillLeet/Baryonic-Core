//
//  PC_Basic_Bullet.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 6/4/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Basic player bullet. Simplified constructor call made into a class for the sake of organization.

import UIKit
import SpriteKit
import GameplayKit

class PC_Basic_Bullet: Bullet{

    convenience init(scale: CGFloat, game_world: GameScene){
        self.init(scale: scale, sprite: "Goodbullet", dmg: 2, type: "PC", game_world: game_world)
        //self.bounces = true
    }

}
