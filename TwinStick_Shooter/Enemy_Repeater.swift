//
//  Enemy_Repeater.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 8/18/20.
//  Copyright © 2020 William Leet. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class Enemy_Repeater: Weapon{
    
    var left: Bool = true

    convenience init(game_world: GameScene!, user: Enemy!, barrel_len: CGFloat){
        self.init(game_world: game_world, ship: user, barrel: barrel_len, firespeed: 3, firerate: 0.3)
    }
    
    override func fire(angle: CGFloat){
        let variance = CGFloat.random(in: -0.1...0.1)
        shoot(angle: angle+variance, to_shoot: Enemy_Basic_Bullet(scale: shooter.xScale * 1.3, game_world: game_scene))
    }
    
    //Since the repeater has two firing nozzles, this overriden "shoot" function alternates the nozzle that the bullet is fired out of!
    override func shoot(angle: CGFloat, to_shoot: Bullet) {
    
        
        //Determines location of ship barrel in accordance to its rotation, places bullet there
        let barrel_coords1 = point_on_circle(angle: angle, circle_size: barrelLength())
        var barrel_coords2: [CGFloat]
        //If left, bullet aligned with left nozzle, else aligned with right nozzle
        if(left){
            barrel_coords2 = point_on_circle(angle: angle+90, circle_size: barrelLength()/8)
        } else {
            barrel_coords2 = point_on_circle(angle: angle-90, circle_size: barrelLength()/8)
        }
        left = !left
        to_shoot.position = CGPoint(x: shooter.position.x - barrel_coords1[0] - barrel_coords2[0], y: shooter.position.y + barrel_coords1[1] + barrel_coords2[1])
           
        //Builds vector used to apply force to bullet
        let trajectory_circle = point_on_circle(angle: angle, circle_size: get_fire_speed()/8)
        let fire = SKAction.applyForce(CGVector(dx: -trajectory_circle[0], dy: trajectory_circle[1]), duration: 0.1)
           
        //Fires bullet, removes it after 15 seconds (should never exist that long anyway)
        to_shoot.run(SKAction.sequence([
            fire,
            SKAction.wait(forDuration: 15),
            SKAction.removeFromParent()
        ]))
           
    }
    
}

