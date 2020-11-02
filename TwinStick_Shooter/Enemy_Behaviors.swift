//
//  Enemy_Behaviors.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 2/3/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  This is where the functions that handle enemy ship movement are kept.

import UIKit
import SpriteKit
import GameplayKit


//Returns a movement to a random point nearby the player within arena bounds
func aggressive_movement(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character, scale: CGFloat, time: Double)-> SKAction{
    //print("Angery!")
    var xvariance: CGFloat = CGFloat(Int.random(in: -100 ..< 100)) * scale
    var yvariance: CGFloat = CGFloat(Int.random(in: -100 ..< 100)) * scale
    var point = CGPoint(x: opponent.position.x + xvariance, y: opponent.position.y + yvariance)
    
    //Continues to load points until it makes one within arena bounds
    while(!scene.arena_bounds.contains(point)){
        xvariance = CGFloat(Int.random(in: -100 ..< 100))  * scale
        yvariance = CGFloat(Int.random(in: -100 ..< 100))  * scale
        point = CGPoint(x: opponent.position.x + xvariance, y: opponent.position.y + yvariance)
    }
    let toreturn: SKAction = SKAction.move(to: point, duration: time)
    //toreturn.timingMode = .easeInEaseOut
    return toreturn
}


//Returns a movement that a point that must be a set distance away from the player
func passive_movement(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character, scale: CGFloat, time: Double)-> SKAction{
    var xvals: [CGFloat] = []
    var yvals: [CGFloat] = []
    let minDist: CGFloat = 100 * scale
    if(opponent.position.x + minDist <= scene.arena_bounds.maxX){
        xvals.append(CGFloat.random(in: opponent.position.x + minDist...scene.arena_bounds.maxX))
    }
    if(opponent.position.x - minDist >= scene.arena_bounds.minX){
        xvals.append(CGFloat.random(in: scene.arena_bounds.minX...opponent.position.x - minDist))
    }
    if(opponent.position.y + minDist <= scene.arena_bounds.maxY){
        yvals.append(CGFloat.random(in: opponent.position.y + minDist...scene.arena_bounds.maxY))
    }
    if(opponent.position.y - minDist >= scene.arena_bounds.minY){
        yvals.append(CGFloat.random(in: scene.arena_bounds.minY...opponent.position.y - minDist))
    }
    if(xvals.isEmpty&&yvals.isEmpty){
        print("Well this can't be good")
        return SKAction.wait(forDuration: time)
    } else {
        let point = CGPoint(x: xvals.randomElement()!, y: yvals.randomElement()!)
        return SKAction.move(to: point, duration: time)
    }
}

//Returns a movement to a random point somewhat nearby the ship within arena bounds
func random_movement(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character, scale: CGFloat, time: Double)->SKAction{
    //print("Random!")
    var xvariance: CGFloat = CGFloat(Int.random(in: -100 ..< 100)) * scale
    var yvariance: CGFloat = CGFloat(Int.random(in: -100 ..< 100)) * scale
    var point = CGPoint(x: ship.position.x + xvariance, y: ship.position.y + yvariance)
    
    //Continues to load points until it makes one within arena bounds
    while(!scene.arena_bounds.contains(point)){
        xvariance = CGFloat(Int.random(in: -100 ..< 100)) * scale
        yvariance = CGFloat(Int.random(in: -100 ..< 100)) * scale
        point = CGPoint(x: ship.position.x + xvariance, y: ship.position.y + yvariance)
    }
    let toreturn: SKAction = SKAction.move(to: point, duration: time)
    //toreturn.timingMode = .easeInEaseOut
    return toreturn

}


//This behvaior makes the ship move erratically, but offesively
func skittish_behavior(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character)->SKAction {
    //Builds action that generates a new aggressive movement and runs it on the ship
    let movement1 = SKAction.run{
        let action = aggressive_movement(scene: scene, ship: ship, opponent: opponent, scale: 0.8, time: 3)
        action.timingMode = .easeInEaseOut
        ship.run(action)
    }
    //Builds action that generates a new random movement and runs it on the ship
    let movement2 = SKAction.run{
        let action = random_movement(scene: scene, ship: ship, opponent: opponent, scale: 2.0, time : 2.4)
        action.timingMode = .easeInEaseOut
        ship.run(action)
    }
    //Performs an aggressive, then random action, with appropriate intermittent pauses
    let move_seq: SKAction = SKAction.sequence([movement1,SKAction.wait(forDuration: 3),movement2,SKAction.wait(forDuration: 2.4)])
    //Loads an action that does this FOREVER
    let toreturn: SKAction = SKAction.repeatForever(move_seq)
    return toreturn
}

//This behvaior makes the ship run at the player (though
func aggressive_behavior(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character)->SKAction {
    //Builds action that generates a new aggressive movement and runs it on the ship
    let movement = SKAction.run{
        ship.run(aggressive_movement(scene: scene, ship: ship, opponent: opponent, scale: 0.5, time: 5))
    }
    //Performs an aggressive, then random action, with appropriate intermittent pauses
    let move_seq: SKAction = SKAction.sequence([movement,SKAction.wait(forDuration: 0.05)])
    //Loads an action that does this FOREVER
    let toreturn: SKAction = SKAction.repeatForever(move_seq)
    return toreturn
}

//This behavior causes the ship to attempt to keep its distance from the player
func cautious_behavior(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character)->SKAction {
    let movement = SKAction.run{
        var action: SKAction!
        if(getDistance(ship.position, opponent.position)<140){
            action = passive_movement(scene: scene, ship: ship, opponent: opponent, scale: 1.2, time : 2.2)
        } else {
            action = random_movement(scene: scene, ship: ship, opponent: opponent, scale: 0.6, time: 2.2)
        }
        action.timingMode = .easeInEaseOut
        ship.run(action)
    }
    //Performs an aggressive, then random action, with appropriate intermittent pauses
    let move_seq: SKAction = SKAction.sequence([movement,SKAction.wait(forDuration: 2.2)])
    //Loads an action that does this FOREVER
    let toreturn: SKAction = SKAction.repeatForever(move_seq)
    return toreturn
}


//This behavior causes the ship to barely move
func sluggish_behavior(scene: GameScene, ship: SKSpriteNode, opponent: Player_Character)->SKAction {
    let movement = SKAction.run{
        let action = random_movement(scene: scene, ship: ship, opponent: opponent, scale: 0.2, time : 2.4)
        action.timingMode = .easeInEaseOut
        ship.run(action)
    }
    //Performs an aggressive, then random action, with appropriate intermittent pauses
    let move_seq: SKAction = SKAction.sequence([movement,SKAction.wait(forDuration: 1.8)])
    //Loads an action that does this FOREVER
    let toreturn: SKAction = SKAction.repeatForever(move_seq)
    return toreturn
}



//Defines action in which a sprite moves in a 'space invaders' style path
//This isn't actually used anywhere in the game.
//Mostly exists as a tutorial I made myself do whilst coding the game's foundations.
//It's still pretty neat, though, so it stays :)
func space_invaders(scene: GameScene) -> SKAction{

    let path = CGMutablePath()
    path.move(to: CGPoint(x: 9 * scene.view!.bounds.width/10, y: 9 * scene.view!.bounds.height/10))
    var heightcounter: Float = 9.0
    var widthcounter: Float = 9.0
    
    while (heightcounter > 0){ //Path Construction
        if(widthcounter == 9){
            widthcounter = 1
            path.addLine(to: CGPoint(x: CGFloat(widthcounter) * scene.view!.bounds.width/10,y: CGFloat(heightcounter) * scene.view!.bounds.height/10))
            heightcounter -= 1.0
            path.addLine(to: CGPoint(x: CGFloat(widthcounter) * scene.view!.bounds.width/10,y: CGFloat(heightcounter) * scene.view!.bounds.height/10))
        }
        else {
            widthcounter = 9
            path.addLine(to: CGPoint(x: CGFloat(widthcounter) * scene.view!.bounds.width/10,y: CGFloat(heightcounter) * scene.view!.bounds.height/10))
            heightcounter -= 1.0
            path.addLine(to: CGPoint(x: CGFloat(widthcounter) * scene.view!.bounds.width/10,y: CGFloat(heightcounter) * scene.view!.bounds.height/10))
        }
    }
    
    heightcounter -= 1.0 //Targets move off-screen
    path.addLine(to: CGPoint(x: CGFloat(widthcounter) * scene.view!.bounds.width/10,y: CGFloat(heightcounter) * scene.view!.bounds.height/10))
   
    //Builds SKAction to follow created path
    let followpath = SKAction.follow(path, asOffset: false, orientToPath: true, speed: 100.0)
    return followpath
}

