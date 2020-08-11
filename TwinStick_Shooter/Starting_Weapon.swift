//
//  Starting_Weapon.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 6/7/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Starting player weapon. Simplified constructor call made into a class for the sake of organization.

import UIKit
import SpriteKit
import GameplayKit

class Starting_Weapon: Weapon{
    
    convenience init(game_world: GameScene!, pcship: Player_Character!, barrel_len: CGFloat){
        self.init(game_world: game_world, ship: pcship, barrel: barrel_len, firespeed: 10, firerate: 0.3)
    }
    
    override func fire(angle: CGFloat){
        self.shoot(angle: angle, to_shoot: PC_Basic_Bullet(scale: shooter.xScale * 1.2, game_world: game_scene))
    }
    
}
