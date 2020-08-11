//
//  Red_Target.swift

//  TwinStick_Shooter
//
//  Created by William Leet on 2/3/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  Prototype enemy. Can be ordered to move in a space-invaders style pattern with total disregard for walls. Can't fight back. Mostly used to test stuff.

import UIKit
import SpriteKit
import GameplayKit



class Red_Target: Enemy{
    
    convenience init(scale: CGFloat, game_world: GameScene){
        self.init(sprite: "Proto Target", scale: scale, game_world: game_world, hp: 3)
    }
    
    override func deploy() {
        self.run(space_invaders(scene: game_scene))
    }
    
}
