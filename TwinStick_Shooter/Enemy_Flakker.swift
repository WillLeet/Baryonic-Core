//
//  Enemy_Skirmisher.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 8/18/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
// A cautious boy that tries to keep its distance, charging up volleys of exceptionally hurty shrapnel bursts

import UIKit
import SpriteKit
import GameplayKit


class Enemy_Flakker: Enemy{
    
    //Is given a weapon and the player's data to help it aim
    var weapon: Weapon!
    
    convenience init(scale: CGFloat, game_world: GameScene){
        self.init(sprite: "Flakker_0", scale: scale, game_world: game_world, hp: 5)
        weapon = Flak_Cannon(game_world: game_scene, user: self, barrel_len: (self.frame.height/1.8))
    }
    
    //Runs the ship's movement and firing behaviors indefinitely.
    override func deploy(){
        let attack: SKAction = SKAction.run{
                self.weapon.fire(angle: self.zRotation)
        }
        let between_shots = SKAction.wait(forDuration: self.weapon.get_fire_rate())
        let firing_seq = SKAction.sequence([between_shots,attack])
        let salvo = SKAction.repeat(firing_seq, count: 4)
        let between_salvos = SKAction.wait(forDuration: 2.4)
        let firing_behavior = SKAction.repeatForever(SKAction.sequence([salvo,between_salvos]))
        let movement_behavior = cautious_behavior(scene: game_scene, ship: self, opponent: opponent)
        self.run(firing_behavior)
        self.run(movement_behavior)
        
    }
    
    override func set_constraints(){
        //Defines a constraint that forces the ship to always face the player
        //This lets it actually fire with some degree of sensibility
        let lookAtConstraint: SKConstraint = SKConstraint.orient(to: opponent, offset: SKRange(constantValue: -CGFloat.pi / 2))
        self.constraints = [lookAtConstraint]
    }
    
}
