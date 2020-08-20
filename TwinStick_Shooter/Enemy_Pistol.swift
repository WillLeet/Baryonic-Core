//
//  Enemy_Pistol.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 6/8/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Basic enemy weapon. Simplified constructor call made into a class for the sake of organization.

import UIKit
import SpriteKit
import GameplayKit


class Enemy_Pistol: Weapon{

    convenience init(game_world: GameScene!, user: Enemy!, barrel_len: CGFloat){
        self.init(game_world: game_world, ship: user, barrel: barrel_len, firespeed: 5, firerate: 1)
    }
    
    override func fire(angle: CGFloat){
        self.shoot(angle: angle, to_shoot: Enemy_Basic_Bullet(scale: shooter.xScale * 1.3, game_world: game_scene))
    }
    
}
