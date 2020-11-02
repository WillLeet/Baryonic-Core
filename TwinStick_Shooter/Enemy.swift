//
//  Enemy.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 2/7/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Basic class for enemies. 'Nuff said

import UIKit
import SpriteKit
import GameplayKit



class Enemy: SKSpriteNode{
    
    var game_scene: GameScene!
    var health: Int = 1
    var ship_scale: CGFloat!
    var ship_model: SKTexture!
    var ship_num: Int!
    var opponent: Player_Character!
    var scrap_value: Int!
    var hitbox_scale: CGFloat!
    
    convenience init(sprite: String, scale: CGFloat, game_world: GameScene, hp: Int, hitbox: CGFloat){
        self.init(imageNamed: sprite)
        self.setScale(scale)
        ship_scale = scale
        game_scene = game_world
        scrap_value = Int.random(in: 1...15)
        hitbox_scale = hitbox
        
        //Updates enemy count and logs ship in the 'current enemies' dictionary
        //The ship's key is saved as 'ship_num' so it can remove itself when killed
        game_scene.enemy_count+=1
        ship_num = game_scene.enemy_count
        game_scene.current_enemies[ship_num] = self
    
        //Sets ship health, stores ship's original texture in 'ship_model',
        //Stores player character data in 'opponent' for aiming/movement behaviors
        health = hp
        ship_model = self.texture!
        opponent = game_scene.PC
        
        //Physicsbodies from textures appear to go off of the original sprite size unless specified
        //Ergo, I have created a "hitbox" CGsize that scales with the sprite to build the body from
        var hitbox: CGSize = self.texture!.size()
        hitbox.width *= scale
        hitbox.height *= scale
        self.physicsBody = SKPhysicsBody(circleOfRadius: hitbox.width * hitbox_scale)
        self.physicsBody!.affectedByGravity = false
        
        //Bitmask labelled as "Enemy", triggers didBegin on contact with player bullets
        //No collision bitmask because I don't wanna deal with them clipping through walls if I goof.
        self.physicsBody!.collisionBitMask = 0x0
        self.physicsBody!.categoryBitMask = CollisionType.Enemy.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.Player_Bullet.rawValue
        self.alpha = 0.0
        game_scene.addChild(self)
       }
    
    //Triggered when damaged. Pretty self-explanatory.
    func damaged(damageValue: Int){
        health -= damageValue
        if(health <= 0){
            self.physicsBody = nil
            die()
        }
    }
    
    //Removes itself from the current enemies dictionary,
    //Updates the enemy count, then deletes itself
    func die(){
        game_scene.current_enemies.removeValue(forKey: ship_num)
        game_scene.enemy_count -= 1
        self.removeFromParent()
        //If this ship's death clears the current room of enemies, opens gates
        if(game_scene.enemy_count==0 && game_scene.current_room.status == "uncleared"){
            game_scene.roomClear()
        }
        game_scene.viewController.updateScrap(value: scrap_value)
        //print(game_scene.current_room.status)
        //print(game_scene.current_room.north?.status as Any)
    }
    
    //An empty 'deploy' function that runs enemy behaviors upon spawning.
    //To be overwritten with the specific enemy AI of each ship!
    func deploy(){
        return
    }

    //An empty 'set_constraints' function that allows constraints to be set for the enemy.
    //To be (potentially) overwritten with the specific enemy AI of each ship!
    func set_constraints(){
        return
    }
    
}
