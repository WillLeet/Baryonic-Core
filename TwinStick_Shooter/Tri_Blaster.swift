//
//  Tri_Blaster.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 10/31/20.
//  Copyright © 2020 William Leet. All rights reserved.
//

import SpriteKit
import GameplayKit


class Tri_Blaster: Weapon{

    convenience init(game_world: GameScene!, user: Enemy!, barrel_len: CGFloat){
        self.init(game_world: game_world, ship: user, barrel: barrel_len, firespeed: 1.7, firerate: 0.1)
    }
    
    override func fire(angle: CGFloat){
        self.shoot(angle: angle, to_shoot: Enemy_Basic_Bullet(scale: shooter.xScale * 1.3, game_world: game_scene))
        self.shoot(angle: angle+(136*(CGFloat.pi/180)), to_shoot: Enemy_Basic_Bullet(scale: shooter.xScale * 1.35, game_world: game_scene))
        self.shoot(angle: angle+(236*(CGFloat.pi/180)), to_shoot: Enemy_Basic_Bullet(scale: shooter.xScale * 1.35, game_world: game_scene))
    }
    
}

