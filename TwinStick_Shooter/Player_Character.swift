//
//  Player_Character.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 1/27/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  I'm making a class, and the class is you! Well, not literally you, but the thing you play as.

import UIKit
import SpriteKit
import GameplayKit

class Player_Character: SKSpriteNode{
    
    var game_scene: GameScene!
    private var barrel_length: CGFloat!
    var ship_scale: CGFloat!
    var current_weapon: Weapon!
    var health: Int!

    convenience init(scale: CGFloat, game_world: GameScene){
        self.init(imageNamed: "PC Basic Design")
        self.setScale(scale)
        ship_scale = scale
        game_scene = game_world
        barrel_length = self.frame.height/2
        current_weapon = Starting_Weapon(game_world: game_scene, pcship: self, barrel_len: barrel_length)
        health = 10
        
        //Physicsbodies from textures appear to go off of the original sprite size unless specified
        //Ergo, I have created a "hitbox" CGsize that scales with the sprite to build the body from
        var hitbox: CGSize = self.texture!.size()
        hitbox.width *= scale
        hitbox.height *= scale
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: hitbox)
        
        //Defines ship's bitmask as player that collides with walls, triggers didBegin on enemy bullets
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.collisionBitMask = CollisionType.Wall.rawValue
        self.physicsBody!.categoryBitMask = CollisionType.Player.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.Enemy_Bullet.rawValue | CollisionType.Gate.rawValue
    }
    
    //Handles the ship's movement on a frame-by frame basis.
    //Takes an x and a y value and sets its movement to said values through applying a vector
    //This lets the ship's movement dynamically respond to the position of the joystick
    func ship_movement(x: CGFloat, y: CGFloat) {
        self.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody!.applyForce(CGVector(dx: x, dy: y))
        //let newlocation = CGPoint(x: self.position.x + x/14, y: self.position.y + y/14)
        //let movement = SKAction.move(to: newlocation, duration: 0.05)
        //self.run(movement)
    }
    
    //Old ship movement function based off of SKActions - really liked to clip through walls!
    /*let newlocation = CGPoint(x: PC.position.x + ship_speedX, y: PC.position.y + ship_speedY)
    let movement = SKAction.move(to: newlocation, duration: 0.1)
    movement.timingMode = .easeOut
    PC.run(movement)
     */
    
    //Handles damage
    func damaged(damageValue: Int){
        //print("Oof owie")
        health = max(health-damageValue,0)
        game_scene.viewController.updateHealth(health: health)
        if(health == 0){
            self.physicsBody = nil
            die()
        }
    }
    
    //Handles player death
    func die(){
        self.removeFromParent()
        game_scene.game_over()
    }
    
    func BAMF(){
        let bamf = SKSpriteNode(imageNamed: "BAMF")
        bamf.setScale(0.1)
        let hitbox_form = SKAction.run{
        bamf.physicsBody = SKPhysicsBody(circleOfRadius: bamf.size.width * bamf.xScale)
        bamf.physicsBody!.collisionBitMask = 0x0
        bamf.physicsBody!.categoryBitMask = CollisionType.Blank.rawValue
        bamf.physicsBody!.contactTestBitMask = CollisionType.Enemy_Bullet.rawValue | CollisionType.Player_Bullet.rawValue
        bamf.physicsBody!.affectedByGravity = false
        }
        let hitbox_seq = SKAction.sequence([hitbox_form,SKAction.wait(forDuration: 0.04)])
        self.game_scene.addChild(bamf)
        bamf.position = self.position
        bamf.run(SKAction.sequence([SKAction.scale(by: 20, duration: 0.4),SKAction.run{bamf.removeFromParent()}]))
        bamf.run(SKAction.repeat(hitbox_seq, count: 10))
    }
    
    func bamf(){
        let bamf = SKSpriteNode(imageNamed: "BAMF")
        bamf.setScale(0.1)
        let hitbox_form = SKAction.run{
        bamf.physicsBody = SKPhysicsBody(circleOfRadius: bamf.size.width * bamf.xScale)
        bamf.physicsBody!.collisionBitMask = 0x0
        bamf.physicsBody!.categoryBitMask = CollisionType.Blank.rawValue
        bamf.physicsBody!.contactTestBitMask = CollisionType.Enemy_Bullet.rawValue | CollisionType.Player_Bullet.rawValue
        bamf.physicsBody!.affectedByGravity = false
        bamf.alpha -= 0.08
        }
        let hitbox_seq = SKAction.sequence([hitbox_form,SKAction.wait(forDuration: 0.04)])
        self.game_scene.addChild(bamf)
        bamf.position = self.position
        bamf.run(SKAction.sequence([SKAction.scale(by: 10, duration: 0.4),SKAction.run{bamf.removeFromParent()}]))
        bamf.run(SKAction.repeat(hitbox_seq, count: 10))
    }
    
}


