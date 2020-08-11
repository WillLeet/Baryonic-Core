//
//  Joystick.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 1/27/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  This class holds and handles tragic yet all too necessary joystick chicanery...

import UIKit
import SpriteKit
import GameplayKit

class Joystick: SKSpriteNode {
    private var base: SKSpriteNode!
    private var stick_position_X: CGFloat = 0.0
    private var stick_position_Y: CGFloat = 0.0
    private var stick_angle: CGFloat?
    private var inUse = false
    var disabled = false

    
    convenience init(base_name: String, stick_name: String, opacity: CGFloat, scale: CGFloat){
        self.init(imageNamed: stick_name)
        self.isUserInteractionEnabled = true
        self.base = SKSpriteNode(imageNamed: base_name)
        self.alpha = opacity
        self.base.alpha = opacity
        self.base.setScale(scale)
        self.setScale(scale)
    }
    
    func get_xPos() -> CGFloat{
        return stick_position_X
    }
    
    func get_yPos() -> CGFloat{
        return stick_position_Y
    }
    
    func get_angle() -> CGFloat{
        return stick_angle!
    }
    
    func is_inUse() -> Bool{
        return inUse
    }
    
    func get_base() -> SKSpriteNode{
        return base
    }
    
    func move_joystick(location: CGPoint){
        if(self.disabled){
            return
        }
            //Sets joystick to 'in use'
            inUse = true
            
            //Sets up joystick bounds
            let vect = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
            stick_angle = atan2(vect.dy,vect.dx)
            let stick_length: CGFloat = base.frame.size.height / 2
            let xDist: CGFloat = sin (stick_angle! - CGFloat(Double.pi/2)) * stick_length
            let yDist: CGFloat = cos (stick_angle! - CGFloat(Double.pi/2)) * stick_length
            
            //Determines joystick location within bounds
            if (base.frame.contains(location)){
                self.position = location
            } else {
            self.position = CGPoint(x: base.position.x - xDist, y: base.position.y + yDist)
            
        }
        //Updates joystick position vars
            stick_position_X = (position.x - base.position.x)
            stick_position_Y = (position.y - base.position.y)
        }
    
    //Determines if a touch is within the joystick's bounds
    func isWithinBounds(touch: CGPoint) -> Bool {
        let xDist_to_stick = abs(touch.x - base.position.x)
        let yDist_to_stick = abs(touch.y - base.position.y)
        let stick_bounds = base.frame.size.height - 10
        return xDist_to_stick < stick_bounds && yDist_to_stick < stick_bounds
    }
    
    //Moves joystick to default position, resets vars accordingly
     func reset_joystick() {
        let reset_position: SKAction = SKAction.move(to: base.position, duration: 0.15)
        reset_position.timingMode = .easeOut
        stick_position_X = 0
        stick_position_Y = 0
        stick_angle = nil
        inUse = false
        //self.run(reset_position)
        self.position = base.position
    }
}
