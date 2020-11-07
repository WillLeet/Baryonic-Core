//
//  PC_Bullet.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 2/2/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Basic 'Bullet' class used by enemies and player alike.

import UIKit
import SpriteKit
import GameplayKit

class Bullet: SKSpriteNode{
    
    var alive = true
    var damage: Int!
    private var bounces = false
    var hitbox: CGSize!
    var game_scene: GameScene!
    
    convenience init(scale: CGFloat, sprite: String, dmg: Int, type: String, game_world: GameScene){
        self.init(imageNamed: sprite)
        self.setScale(scale)
        damage = dmg
        game_scene = game_world
        game_world.addChild(self)
        //Physicsbodies from textures appear to go off of the original sprite size unless specified
        //Ergo, I have created a "hitbox" CGsize that scales with the sprite to build the body from
        hitbox = self.texture!.size()
        hitbox.width *= scale
        hitbox.height *= scale
        self.physicsBody = SKPhysicsBody(circleOfRadius: hitbox.height * 0.5)
        self.physicsBody!.affectedByGravity = false
        
        // 'Restitution' determines how much momentum is gained or lost upon collision.
        //  I have set it to 1, meaning that velocity is neither gained nor lost when a bullet hits a wall. Lets them ricochet semi-usefully, if I want a bullet to do that.
        self.physicsBody!.restitution = 1.0
        
        if type == "PC"{
            self.physicsBody!.categoryBitMask = CollisionType.Player_Bullet.rawValue
            self.physicsBody!.collisionBitMask = CollisionType.Wall.rawValue
            self.physicsBody!.contactTestBitMask = CollisionType.Enemy.rawValue | CollisionType.Wall.rawValue
        } else if type == "Enemy"{
            self.physicsBody!.categoryBitMask = CollisionType.Enemy_Bullet.rawValue
            self.physicsBody!.collisionBitMask = CollisionType.Wall.rawValue
            self.physicsBody!.contactTestBitMask = CollisionType.Player.rawValue | CollisionType.Wall.rawValue
            | CollisionType.Blank.rawValue
        }
        
        //Sets zposition as "Bullet" type
        self.zPosition = ZPositions.Bullet.rawValue
        
    }
    
    func impact(){
        self.physicsBody = nil
        self.removeFromParent()
    }
    
    //I don't really want anything changing these variables. Ergo, they're private with getters. 
    
    func can_bounce() -> Bool {
        return bounces
    }
    
    func get_damage() -> Int{
        return damage
    }
    
    //Called when the bullet bounces off of something. Might well need this at some point.
    func bounced(){
        return
    }
}

