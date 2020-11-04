//
//  Spawner.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 6/5/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  This class handles spawning things!


import UIKit
import SpriteKit
import GameplayKit

class Spawner{
    

    var credits: Int!
    var spawnList: Dictionary<Int, [String]> = [:]
    var canSpawn = [Int]()
    var game_scene: GameScene!

    init(game_world: GameScene, danger_val: Int){
        game_scene = game_world
        credits = danger_val
        
    }
    
    func setSpawns(_ dict: Dictionary<Int, [String]>){
        spawnList = dict
    }
    
    func generateEnemy(_ name: String){
        if(name=="Basic Enemy"){
            game_scene.spawn(Basic_Enemy(scale: 0.25, game_world: game_scene))
        } else if(name=="Enemy Skirmisher"){
            game_scene.spawn(Enemy_Skirmisher(scale: 0.2, game_world: game_scene))
        } else if(name=="Enemy Flakker"){
            game_scene.spawn(Enemy_Flakker(scale: 0.22, game_world: game_scene))
        } else if(name=="Enemy Triangulator"){
            game_scene.spawn(Enemy_Triangulator(scale: 0.22, game_world: game_scene))
        } else {
            game_scene.spawn(Red_Target(scale: 0.2, game_world: game_scene))
        }
    }
    
    func fixedSpawn(){
        return
    }

    func Spawn(){
        canSpawn = Array(spawnList.keys)
        var spawnCount = 0
        var balance = credits!
        var spawnValue = 0
        var toSpawn: String = ""
        while(balance > 0 && spawnCount < 7 && !canSpawn.isEmpty){
            print(canSpawn)
            spawnCount += 1
            spawnValue = canSpawn.randomElement()!
            balance -= spawnValue
            toSpawn = spawnList[spawnValue]!.randomElement()!
            generateEnemy(toSpawn)
            print("Spawning ",toSpawn)
            canSpawn.removeAll(where: {$0 > balance})
        }
    }
    
}
    
