//
//  Gate.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 6/27/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
// Wall subclass used to handle the gates between rooms.
// Comes with additional functions to let it change its bitmask and opacity accordingly

import UIKit
import SpriteKit
import GameplayKit

class Gate: Wall{
    
    var direction: String!
    var locked: Bool = false

    //For the sake of practicality, gates can only use the more specific Wall constructor
    //The gate will be initialized as open
    convenience init(sprite: String, width: CGFloat, height: CGFloat, game_world: GameScene, place: String, open: Bool){
        self.init(sprite: sprite, width: width, height: height, game_world: game_world)
        if(open){
            //Sets bitmask settings to Gate, makes sprite transparent
            self.physicsBody!.categoryBitMask = CollisionType.Gate.rawValue
            self.physicsBody!.collisionBitMask = 0x0
            self.physicsBody!.contactTestBitMask = CollisionType.Player.rawValue
            self.alpha = 0.0
        }
        direction = place
    }
    
    func setClosed(){
    //Sets bitmask settings to Wall, makes sprite opaque
    self.physicsBody!.categoryBitMask = CollisionType.Wall.rawValue
    self.physicsBody!.collisionBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Player.rawValue
    self.physicsBody!.contactTestBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Enemy_Bullet.rawValue
    self.alpha = 1.0
    }
    
    func setOpen(){
    //Sets bitmask settings to Gate, makes sprite transparent
    self.physicsBody!.categoryBitMask = CollisionType.Gate.rawValue
    self.physicsBody!.collisionBitMask = 0x0
    self.physicsBody!.contactTestBitMask = CollisionType.Player.rawValue
    self.alpha = 0.0
    }
    
    func open(){
        //Functionally the same as 'setOpen', but fades the gate sprite out
        //Sets bitmask settings to Gate, makes sprite transparent
        self.physicsBody!.categoryBitMask = CollisionType.Gate.rawValue
        self.physicsBody!.collisionBitMask = 0x0
        self.physicsBody!.contactTestBitMask = CollisionType.Player.rawValue
        //Fades in the gate sprite
        self.run(SKAction.repeat((SKAction.sequence([
            SKAction.wait(forDuration: 0.02),
            SKAction.run{
                self.alpha -= 0.05
            }
        ])), count: 20))
        
    }
    
    func close(){
        //Functionally the same as 'setClosed', but fades the gate sprite in
        self.physicsBody!.categoryBitMask = CollisionType.Wall.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Player.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Enemy_Bullet.rawValue
        self.run(SKAction.repeat((SKAction.sequence([
            SKAction.wait(forDuration: 0.02),
            SKAction.run{
                self.alpha += 0.05
            }
        ])), count: 20))
    }
    
}
