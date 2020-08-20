//
//  Flak_Cannon.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 8/20/20.
//  Copyright © 2020 William Leet. All rights reserved.
//

import SpriteKit
import GameplayKit


class Flak_Cannon: Weapon{

    convenience init(game_world: GameScene!, user: Enemy!, barrel_len: CGFloat){
        self.init(game_world: game_world, ship: user, barrel: barrel_len, firespeed: 2.5, firerate: 0.6)
    }
    
    override func fire(angle: CGFloat){
        var variance: CGFloat = 0.0
        for _ in 0...3 {
            variance = CGFloat.random(in: -0.6...0.6)
            self.shoot(angle: angle+variance, to_shoot: Enemy_Basic_Bullet(scale: shooter.xScale * 1.5, game_world: game_scene))
        }
 
    }
    
}
