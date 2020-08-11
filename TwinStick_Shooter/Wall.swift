//
//  Wall.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 3/31/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Wall class, mostly used to build the arena the ships fight in.
//  I could theoretically also use this to add walls *inside* the arena!
//  But heck, arena's small enough as is. I might not want to get that spicy...

import UIKit
import SpriteKit
import GameplayKit

class Wall: SKSpriteNode{
    
    var game_scene: GameScene!
       
    //A more flexible constructor that just builds the wall around the given (scaled) texture. 
    convenience init(sprite: String, scale: CGFloat, game_world: GameScene){
        self.init(imageNamed: sprite)
        self.setScale(scale)
        game_scene = game_world
        game_scene.addChild(self)
        //Physicsbodies from textures appear to go off of the original sprite size unless specified
        //Ergo, I have created a "hitbox" CGsize that scales with the sprite to build the body from
        var hitbox: CGSize = self.texture!.size()
        hitbox.width *= scale
        hitbox.height *= scale
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: hitbox)
        
        //Locks wall in place, preventing collisions from moving it
        self.physicsBody!.pinned = true
        self.physicsBody!.allowsRotation = false
        
        //Defines wall's bitmask, what the wall can collide with, and what triggers DidBegin
        self.physicsBody!.categoryBitMask = CollisionType.Wall.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Player.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Enemy_Bullet.rawValue
       }
    
    //A constructor that defines precise width and height bounds, for arena construction
    convenience init(sprite: String, width: CGFloat, height: CGFloat, game_world: GameScene){
        self.init(imageNamed: sprite)
        game_scene = game_world
        game_scene.addChild(self)
        self.size = CGSize(width: width, height: height)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        self.physicsBody!.affectedByGravity = false
        
        //Locks wall in place, preventing collisions from moving it
        self.physicsBody!.isDynamic = false
        self.physicsBody!.allowsRotation = false
     
        //Defines wall's bitmask, what the wall can collide with, and what triggers DidBegin
        self.physicsBody!.categoryBitMask = CollisionType.Wall.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Player.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.Player_Bullet.rawValue | CollisionType.Enemy_Bullet.rawValue
        }
    
    //Lets me delete walls! Will probably need this for room transitioning, I'd imagine. 
    func delete(){
        self.physicsBody = nil
        self.removeFromParent()
    }
    

}

