//
//  Weapon.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 6/5/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Basic 'Weapon' class used by enemies and player alike.
//  Instantiated separately from the ships themselves to help me cleanly handle multiple or changing weapons for enemies and players respectively. 


import UIKit
import SpriteKit
import GameplayKit

class Weapon: NSObject{
    
    private var ready_to_fire: Bool = true
    var game_scene: GameScene!
    private var fire_rate: Double!
    private var barrel_length: CGFloat!
    private var firing_speed: CGFloat!
    var shooter: SKSpriteNode!

    init(game_world: GameScene, ship: SKSpriteNode, barrel: CGFloat, firespeed: CGFloat, firerate: Double){
        game_scene = game_world
        shooter = ship
        barrel_length = barrel
        firing_speed = firespeed
        fire_rate = firerate
    }
    
    //This variable does need a getter, but since I don't want anything else in my code messing with it, it does not get a setter. Tragic, I know.
    func canFire() -> Bool {
        return ready_to_fire
    }
       
    
    // Why did I decide that fire rate *specifically* should be a private variable with getters and setters whilst every single other class variable modified by other classes I've implemented are just public? Truly, these are the mysteries that keep me up at night.
    func get_fire_rate() -> Double{
        return fire_rate
    }
       
    func set_fire_rate(new_fire_rate: Double){
           fire_rate = new_fire_rate
       }
     
    func get_fire_speed() -> CGFloat{
        return firing_speed
    }
       
    func set_fire_speed(new_firing_speed: CGFloat){
           firing_speed = new_firing_speed
       }
    
    func barrelLength() -> CGFloat{
        return barrel_length
    }
    
    //A generic "fire" class that will be overridden by the specific properties of each weapon
    func fire(angle: CGFloat){
        return
    }
    
    // Takes projectile and angle arguments, letting me potentially make one weapon capable of firing multiple different types of bullet
    func shoot(angle: CGFloat, to_shoot: Bullet) {
           
        //Puts weapon on cool-down, creates new bullet from given bullet class
        self.ready_to_fire = false
           
        //Determines location of ship barrel in accordance to its rotation, places bullet there
        let barrel_coords = point_on_circle(angle: angle, circle_size: barrel_length)
        to_shoot.position = CGPoint(x: shooter.position.x - barrel_coords[0], y: shooter.position.y + barrel_coords[1])
           
        //Builds vector used to apply force to bullet
        let trajectory_circle = point_on_circle(angle: angle, circle_size: firing_speed/6)
        let fire = SKAction.applyForce(CGVector(dx: -trajectory_circle[0], dy: trajectory_circle[1]), duration: 0.1)
           
        //Fires bullet, removes it after 15 seconds (should never exist that long anyway)
        to_shoot.run(SKAction.sequence([
            fire,
            SKAction.wait(forDuration: 15),
            SKAction.removeFromParent()
        ]))
           
        //Sets weaponn as ready to fire after fire_rate period has elapsed
        DispatchQueue.main.asyncAfter(deadline: .now() + fire_rate) {
            self.ready_to_fire = true
        }
           
    }
    
}
