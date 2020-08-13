//
//  GameScene.swift
//  Twinmovement_stick_Shooter
//
//  Created by William Leet on 1/13/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
//  The actual game code. This is where the magic happens.

import SpriteKit
import GameplayKit

//This was originally a struct until I decided to let it hold itself.
class Room{
    var type: String = "standard"
    var west: Room?
    var east: Room?
    var north: Room?
    var south: Room?
    var status: String = "uncleared"
    var seen: Bool = false
    var playerIn: Bool = false
    init() { }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var PC: Player_Character!
    var ship_speedX: CGFloat = 0
    var ship_speedY: CGFloat = 0
    var movement_stick: Joystick!
    var shooting_stick: Joystick!
    var viewController: GameViewController!
    var arena_bounds: CGRect!
    var arena: Dictionary<String, Wall> = [:]
    var next_arena: Dictionary<String, Wall> = [:]
    //var arena_holder: Dictionary<String, Wall> = [:]
    var enemy_count: Int = 0
    var current_enemies: Dictionary<Int, Enemy> = [:]
    var enemy_dict: Dictionary<String, Enemy> = [:]
    var current_room: Room!
    var current_level: [[Room]] = []
    let level_size: Int = 8
    var transition_check: String = "none"
    var xcoords: Int = 0
    var ycoords: Int = 0
    //var safety_on: Bool = false
    
    
    
    
    
    override func didMove(to view: SKView) {
        
        //Sets up physics contact delegate in game scene
        self.physicsWorld.contactDelegate = self
        
        //Sets background and initial anchor point
        self.backgroundColor = SKColor.white
        self.anchorPoint = CGPoint(x: 0.0,y: 0.0)
        
        //Sets up movement joystick
        movement_stick = Joystick(base_name: "Joystick_Base",stick_name: "Joystick_stick", opacity: 0.4, scale: 1.1)
        self.addChild(movement_stick)
        let movement_base: SKSpriteNode = movement_stick.get_base()
        self.addChild(movement_base)
        //movement_base.position = CGPoint(x: self.view!.bounds.width/8, y: 24*self.view!.bounds.height/100)
        movement_base.position = CGPoint(x: 32.0+viewController.movestick_base.frame.width/2-viewController.movestick_base.frame.width/15, y: 38.0+viewController.movestick_base.frame.height/2-viewController.movestick_base.frame.height/15)
        movement_stick.position = movement_base.position
        
        //Sets up shooting joystick
        shooting_stick = Joystick(base_name: "Shooting_Base",stick_name: "Shooting_stick", opacity: 0.4, scale: 1.1)
        self.addChild(shooting_stick)
        let shooting_base: SKSpriteNode = shooting_stick.get_base()
        self.addChild(shooting_base)
        //shooting_base.position = CGPoint(x: (7 * self.view!.bounds.width/8), y: self.view!.bounds.height/5)
        shooting_base.position = CGPoint(x: self.view!.bounds.width-32.0-viewController.movestick_base.frame.width/2+viewController.movestick_base.frame.width/15, y: 38.0+viewController.movestick_base.frame.height/2-viewController.movestick_base.frame.height/15)
        shooting_stick.position = shooting_base.position
        
        
        //Builds player-controlled character
        PC = Player_Character(scale: 0.25, game_world: self)
        
        PC.position = CGPoint(x: self.view!.bounds.width/2, y: self.view!.bounds.height/2)
        self.addChild(PC)
        
        //Builds the current level
        generateLevel()
        
        
        
        //Builds current and next arena
        //current_room = current_level[5][3]
        //arena = construct_arena(room: current_room, centerx: self.view!.bounds.width/2, centery: self.view!.bounds.height/2, opengates: false)
        
        //Defines arena bounds to help with enemy ship movement
        arena_bounds = CGRect(origin: CGPoint(x: self.view!.bounds.width/3.65, y: self.view!.bounds.height/12), size: CGSize(width: 4.5*self.view!.bounds.width/10, height: 8.4*self.view!.bounds.height/10))
        
        //Creates sprite node to highlight arena bounds in red for testing purposes
        //let bounds_test = SKSpriteNode(color: UIColor.systemRed, size: arena_bounds.size)
        //bounds_test.position = CGPoint(x: arena_bounds.midX, y: arena_bounds.midY)
        //self.addChild(bounds_test)
        
        spawn_enemies()
 
        //For whatever reason, the code needs a moment before it figures out how big frames are
        //Delaying the initial map draw lets it work this out so that it *doesn't* draw the first map square in the wrong place and size for some reason
        //There's probably a smarter way of doing this, but if it works...
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewController.map_display.updateMap(scene: self)
        }

    }
    
    func decelerate(value: CGFloat) -> CGFloat { //Decreases ship speed gradually
        var newvalue = abs(value)
        let negative: Bool = value < 0.0
        newvalue *= newvalue > 0.5 ? 0.9 : 0.0 //Decreases speed if speed > 0.5, else sets to 0
        newvalue *= negative ? -1.0 : 1.0 //Re-assigns negative value if necessary
        return newvalue
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            //Moves joysticks if touch is within either joystick's bounds
            let location = touch.location(in: self)
            if(movement_stick.isWithinBounds(touch: location)){
                movement_stick.move_joystick(location: location)
                //viewController.movestick_base.image = UIImage(named: "Movepad Pressed")
                //viewController.updateJoystick(stick: "move", x: movement_stick.position.x, y: movement_stick.position.y)
            }
            if(shooting_stick.isWithinBounds(touch: location)){
                shooting_stick.move_joystick(location: location)
                //viewController.shootstick_base.image = UIImage(named: "Shootpad Pressed")
                //viewController.updateJoystick(stick: "shoot", x: shooting_stick.frame.origin.x, y: shooting_stick.frame.origin.y)
            }
        }
    
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            //Moves joysticks if touch is within either joystick's bounds
            let location = touch.location(in: self)
            if(movement_stick.isWithinBounds(touch: location)){
                movement_stick.move_joystick(location: location)
                //viewController.updateJoystick(stick: "move", x: movement_stick.position.x, y: movement_stick.position.y)
            }
            if(shooting_stick.isWithinBounds(touch: location)){
                shooting_stick.move_joystick(location: location)
                //viewController.updateJoystick(stick: "shoot", x: shooting_stick.frame.origin.x, y: shooting_stick.frame.origin.y)
            }
        }
    
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           for touch: AnyObject in touches {
            //print(enemy_count)
            
            //Resets joysticks
            let location = touch.location(in: self)
            if(movement_stick.is_inUse() && location.x <= self.view!.bounds.width/2) {
                movement_stick.reset_joystick()
                //viewController.movestick_base.image = UIImage(named: "Movepad Unpressed")
                //viewController.updateJoystick(stick: "move", x: movement_stick.position.x, y: movement_stick.position.y)
            }
            
            if(shooting_stick.is_inUse() && location.x > self.view!.bounds.width/2){
                shooting_stick.reset_joystick()
                //viewController.shootstick_base.image = UIImage(named: "Shootpad Unpressed")
                //viewController.updateJoystick(stick: "shoot", x: shooting_stick.frame.origin.x, y: shooting_stick.frame.origin.y)
            }
            
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        //Moves ship if movement stick is being used, else decelerates ship
        if(movement_stick.is_inUse()){
            ship_speedX = movement_stick.get_xPos() * 2
            ship_speedY = movement_stick.get_yPos() * 2
        }
        else if(ship_speedX != 0 || ship_speedY != 0){
            ship_speedX = decelerate(value: ship_speedX)
            ship_speedY = decelerate(value: ship_speedY)
        }
        
        //If shooting stick is being used, rotates ship
        if(shooting_stick.is_inUse()){
            let ship_angle = shooting_stick.get_angle() - CGFloat(Double.pi/2)
            PC.zRotation = ship_angle
            
            //If ship's gun is off cooldown, fires
            if(PC.current_weapon.canFire()){
                PC.current_weapon.fire(angle: ship_angle)
            }
        }
        
        //Updates ship position
        PC.ship_movement(x: ship_speedX, y: ship_speedY)
        
        //Calls 'roomTransition' for didBegin
        //"Why can't didBegin just call this function itself?", you may be asking
        //To which I would say THAT'S A GOOD FRIGGIN QUESTION
        if(transition_check != "none"){
            PC.physicsBody!.categoryBitMask = 0x0
            roomTransition(movingto: transition_check)
            transition_check = "none"
        }
    }
    
    //Prototype game over. Triggers if the player ship dies.
    func game_over(){
        self.isPaused = true
        let alert = UIAlertController(title: "You lose!", message: "Game over, man. Game over!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK, start new game", style: .default, handler: {action in self.respawn()}))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    //Prototype new game. Respawns ship.
    func respawn(){
        PC = Player_Character(scale: 0.25, game_world: self)
        PC.position = CGPoint(x: self.view!.bounds.width/2, y: self.view!.bounds.height/2)
        self.addChild(PC)
        self.isPaused = false
        
        
        for (_, enemy) in current_enemies{
            //Resets enemy constraints so they aren't shooting at a corpse.
            enemy.opponent = PC
            enemy.set_constraints()
        }
    }
    
    //Function for spawning enemies
    func spawn(tospawn: Enemy){
        //Randomly generates spawn point within arena bounds
        let spawnx = CGFloat.random(in: self.arena_bounds.minX...self.arena_bounds.maxX)
        let spawny = CGFloat.random(in: self.arena_bounds.minY...self.arena_bounds.maxY)
        tospawn.position = CGPoint(x: spawnx, y: spawny)
        //Turns off physics body for ship's spawn animation
        let disable_physicsbody = SKAction.run{
            tospawn.physicsBody!.categoryBitMask = 0x0
        }
        let flashIn = SKAction.run {
            tospawn.alpha = 1.0
        }
        let flashOut = SKAction.run {
            tospawn.alpha = 0.0
        }
        //Sets up spawn aimation
        let pause = SKAction.wait(forDuration: 0.3)
        let short_pause = SKAction.wait(forDuration: 0.03)
        let flash_seq = SKAction.sequence([flashIn,pause,flashOut,pause])
        let spawn_alert = SKAction.repeat(flash_seq, count: 4)
       
        let opacity_shift = SKAction.run {
            tospawn.alpha += 0.05
        }
        let fade_increment = SKAction.sequence([opacity_shift,short_pause])
        let fadeIn = SKAction.repeat(fade_increment, count: 20)
        
        let alert_texture = SKAction.setTexture(SKTexture(imageNamed: "Spawn Alert"))
        let actual_texture = SKAction.setTexture(tospawn.ship_model)
        let activate_constraints = SKAction.run{
            tospawn.set_constraints()
        }
        let activate_enemy = SKAction.run{
            tospawn.physicsBody!.categoryBitMask = CollisionType.Enemy.rawValue
            tospawn.deploy()
        }
        //Runs animation
        tospawn.run(SKAction.sequence([disable_physicsbody,alert_texture,spawn_alert,actual_texture,activate_constraints,fadeIn,activate_enemy]))
    }
    
    
    //Builds an arena around a given centerpoint.
     //This entire function is a horrifying mess of fractions and madness.
     //I refuse to comment it. Just trust that it works.
     func construct_arena(room: Room, centerx: CGFloat, centery: CGFloat, opengates: Bool) ->  Dictionary<String, Wall> {
         var arena_dict: Dictionary<String, Wall> = [:]
         var ne_corner: Wall
         var nw_corner: Wall
         var se_corner: Wall
         var sw_corner: Wall
         
         //Builds north wall
         if(room.north == nil){
             let north_wall = Wall(sprite: "Full Wall", width: 5.5*self.view!.bounds.width/10 - 2*self.view!.bounds.width/40 - 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             north_wall.position = CGPoint(x: centerx, y: centery + self.view!.bounds.height/2 - north_wall.size.height/2)
             north_wall.yScale = north_wall.yScale * -1
             ne_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             ne_corner.position = CGPoint(x: north_wall.frame.maxX + ne_corner.frame.width/2 - self.view!.bounds.width/660, y: north_wall.frame.minY)
             nw_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             nw_corner.position = CGPoint(x: north_wall.frame.minX - ne_corner.frame.width/2 + self.view!.bounds.width/660, y: north_wall.frame.minY)
             
             arena_dict["north wall"] = north_wall
             arena_dict["ne corner"] = ne_corner
             arena_dict["nw corner"] = nw_corner
             
         } else {
             let north_gate = Gate(sprite: "Gate", width: 5.5*self.view!.bounds.width/20, height: self.view!.bounds.height/50, game_world: self, place: "N", open: opengates)
             north_gate.position = CGPoint(x: centerx, y: centery + self.view!.bounds.height/2 - north_gate.size.height/2)
             north_gate.yScale = north_gate.yScale * -1
             let north_seg1 = Wall(sprite: "Wall Segment", width: 5.5*self.view!.bounds.width/40 - self.view!.bounds.width/40, height: self.view!.bounds.height/50, game_world: self)
             north_seg1.position = CGPoint(x: north_gate.frame.minX - north_seg1.size.width/2 + 2*self.view!.bounds.width/660, y: north_gate.position.y)
             let north_seg2 = Wall(sprite: "Wall Segment", width: 5.5*self.view!.bounds.width/40 - self.view!.bounds.width/40, height: self.view!.bounds.height/50, game_world: self)
             north_seg2.position = CGPoint(x: north_gate.frame.maxX + north_seg2.size.width/2 - self.view!.bounds.width/660, y: north_gate.position.y)
             
             ne_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             ne_corner.position = CGPoint(x: north_seg2.frame.maxX + ne_corner.frame.width/2 - self.view!.bounds.width/660, y: north_seg2.frame.minY)
             nw_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             nw_corner.position = CGPoint(x: north_seg1.frame.minX - ne_corner.frame.width/2 + self.view!.bounds.width/660, y: north_seg2.frame.minY)
             
             arena_dict["north gate"] = north_gate
             arena_dict["north seg1"] = north_seg1
             arena_dict["north seg2"] = north_seg2
             arena_dict["ne corner"] = ne_corner
             arena_dict["nw corner"] = nw_corner
         }
         
         //Builds south wall
         if(room.south == nil){
             let south_wall = Wall(sprite: "Full Wall", width: 5.5*self.view!.bounds.width/10 - 2*self.view!.bounds.width/40 - 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             south_wall.position = CGPoint(x: centerx, y: centery - self.view!.bounds.height/2 + south_wall.size.height/2 - self.view!.bounds.height/370)
             se_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
                 se_corner.position = CGPoint(x: south_wall.frame.maxX + se_corner.frame.width/2 - self.view!.bounds.width/660, y: south_wall.frame.maxY)
             sw_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             sw_corner.position = CGPoint(x: south_wall.frame.minX - sw_corner.frame.width/2 + self.view!.bounds.width/660, y: south_wall.frame.maxY)
                    
             arena_dict["south wall"] = south_wall
             arena_dict["se corner"] = se_corner
             arena_dict["sw corner"] = sw_corner
                    
         } else {
             let south_gate = Gate(sprite: "Gate", width: 5.5*self.view!.bounds.width/20, height: self.view!.bounds.height/50, game_world: self, place: "S", open: opengates)
             south_gate.position = CGPoint(x: centerx, y: centery - self.view!.bounds.height/2 + south_gate.size.height/2)
             let south_seg1 = Wall(sprite: "Wall Segment", width: 5.5*self.view!.bounds.width/40 - self.view!.bounds.width/40, height: self.view!.bounds.height/50, game_world: self)
             south_seg1.position = CGPoint(x: south_gate.frame.minX - south_seg1.size.width/2 + 2*self.view!.bounds.width/660, y: south_gate.position.y)
             let south_seg2 = Wall(sprite: "Wall Segment", width: 5.5*self.view!.bounds.width/40 - self.view!.bounds.width/40, height: self.view!.bounds.height/50, game_world: self)
             south_seg2.position = CGPoint(x: south_gate.frame.maxX + south_seg2.size.width/2 - self.view!.bounds.width/660, y: south_gate.position.y)
                    
             se_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             se_corner.position = CGPoint(x: south_seg2.frame.maxX + se_corner.frame.width/2 - self.view!.bounds.width/660, y: centery - self.view!.bounds.height/2 + se_corner.size.height/2)
             sw_corner = Wall(sprite: "Wall Corner", width: self.view!.bounds.width/40, height: self.view!.bounds.width/40, game_world: self)
             sw_corner.position = CGPoint(x: south_seg1.frame.minX - sw_corner.frame.width/2 + self.view!.bounds.width/660, y: centery - self.view!.bounds.height/2 + se_corner.size.height/2)
                    
             arena_dict["south gate"] = south_gate
             arena_dict["south seg1"] = south_seg1
             arena_dict["south seg2"] = south_seg2
             arena_dict["se corner"] = se_corner
             arena_dict["sw corner"] = sw_corner
         }
         
         //Builds east wall
         if(room.east == nil){
             let east_wall = Wall(sprite: "Full Wall", width: self.view!.bounds.height - 2*self.view!.bounds.width/40 + 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             east_wall.zRotation = .pi / 2
             east_wall.position = CGPoint(x: se_corner.position.x+east_wall.frame.width/2 + self.view!.bounds.width/660, y:centery - 0.5*self.view!.bounds.height/375)
             
             arena_dict["east wall"] = east_wall
         } else {
             let east_gate = Gate(sprite: "Gate", width: self.view!.bounds.height/2, height: self.view!.bounds.height/50, game_world: self, place: "E", open: opengates)
             east_gate.zRotation = .pi / 2
             east_gate.position = CGPoint(x: se_corner.position.x+east_gate.frame.width/2 + self.view!.bounds.width/660, y:centery)
             let east_seg1 = Wall(sprite: "Wall Segment", width: self.view!.bounds.height/4 - self.view!.bounds.width/40 + 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             east_seg1.zRotation = .pi / 2
             east_seg1.position = CGPoint(x: east_gate.position.x, y: east_gate.frame.minY - east_seg1.size.width/2  + 2*self.view!.bounds.height/375)
             let east_seg2 = Wall(sprite: "Wall Segment", width: self.view!.bounds.height/4 - self.view!.bounds.width/40 + 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             east_seg2.zRotation = .pi / 2
             east_seg2.position = CGPoint(x: east_gate.position.x, y: east_gate.frame.maxY + east_seg1.size.width/2  - 1.5*self.view!.bounds.height/375)
                    
                    
             arena_dict["east gate"] = east_gate
             arena_dict["east seg1"] = east_seg1
             arena_dict["east seg2"] = east_seg2
         }
         
         //Builds west wall
         if(room.west == nil){
             let west_wall = Wall(sprite: "Full Wall", width: self.view!.bounds.height - 2*self.view!.bounds.width/40 + 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             west_wall.zRotation = -.pi / 2
             west_wall.position = CGPoint(x: sw_corner.position.x-west_wall.frame.width/2 - self.view!.bounds.width/660, y:centery - 0.5*self.view!.bounds.height/375)
             
             arena_dict["west wall"] = west_wall
         } else {
             let west_gate = Gate(sprite: "Gate", width: self.view!.bounds.height/2, height: self.view!.bounds.height/50, game_world: self, place: "W", open: opengates)
             west_gate.zRotation = -.pi / 2
             west_gate.position = CGPoint(x: sw_corner.position.x-west_gate.frame.width/2 - self.view!.bounds.width/660, y: centery)
             let west_seg1 = Wall(sprite: "Wall Segment", width: self.view!.bounds.height/4 - self.view!.bounds.width/40 + 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             west_seg1.zRotation = -.pi / 2
             west_seg1.position = CGPoint(x: west_gate.position.x, y: west_gate.frame.minY - west_seg1.size.width/2 + 2*self.view!.bounds.height/375)
             let west_seg2 = Wall(sprite: "Wall Segment", width: self.view!.bounds.height/4 - self.view!.bounds.width/40 + 3*self.view!.bounds.width/660, height: self.view!.bounds.height/50, game_world: self)
             west_seg2.zRotation = -.pi / 2
             west_seg2.position = CGPoint(x: west_gate.position.x, y: west_gate.frame.maxY + west_seg1.size.width/2  - 2*self.view!.bounds.height/375)
                    
                    
             arena_dict["west gate"] = west_gate
             arena_dict["west seg1"] = west_seg1
             arena_dict["west seg2"] = west_seg2
         }
         
         //se_corner.setScale(1.02)
         //sw_corner.setScale(1.02)
         //ne_corner.setScale(1.02)
         //nw_corner.setScale(1.02)
         return arena_dict
     }
    
    
    //Opens all the gates in the current room
    func openGates(){
        //print("Opening Gates!")
        if let north_gate: Gate = arena["north gate"] as? Gate{
            north_gate.open()
        }
        if let south_gate: Gate = arena["south gate"] as? Gate{
            south_gate.open()
        }
        if let east_gate: Gate = arena["east gate"] as? Gate{
            east_gate.open()
        }
        if let west_gate: Gate = arena["west gate"] as? Gate{
            west_gate.open()
        }
    }
    
    //Closes all the gates in the current room
    func closeGates(){
        //print("Closing Gates!")
        if let north_gate: Gate = arena["north gate"] as? Gate{
            north_gate.close()
        }
        if let south_gate: Gate = arena["south gate"] as? Gate{
            south_gate.close()
        }
        if let east_gate: Gate = arena["east gate"] as? Gate{
            east_gate.close()
        }
        if let west_gate: Gate = arena["west gate"] as? Gate{
            west_gate.close()
        }
    }
    
    //Creates a level
    func generateLevel(){
        
        for _ in 1...level_size{
            var row: [Room] = []
            for _ in 1...level_size{
                let element = Room()
                row.append(element)
            }
            current_level.append(row)
        }
        //print(current_level)
        for i in 0...level_size-1{
            for j in 0...level_size-1{
                //print(i,",",j)
                if (i)>0{
                    current_level[i][j].west = current_level[i-1][j]
                }
                if (i)<level_size-1{
                    current_level[i][j].east = current_level[i+1][j]
                }
                if (j)>0{
                    current_level[i][j].south = current_level[i][j-1]
                }
                if (j)<level_size-1{
                    current_level[i][j].north = current_level[i][j+1]
                }
            }
        }
        
        //current_room = current_level[5][3]
        //arena = construct_arena(room: current_room, centerx: self.view!.bounds.width/2, centery: self.view!.bounds.height/2, opengates: false)
        //Int.random(in: 0...level_size)
        xcoords = 3
        ycoords = 4
        current_room = current_level[xcoords][ycoords]
        arena = construct_arena(room: current_room, centerx: self.view!.bounds.width/2, centery: self.view!.bounds.height/2, opengates: false)
    }
    
    //Checks if a room has any neighbors
    func hasNeighbor(room: Room) -> Bool {
        if(room.east==nil && room.north==nil && room.south==nil && room.west==nil){
            return false
        } else {
        return true
        }
    }
    
    //Transitions the player from one room to the next
    func roomTransition(movingto: String){
        current_room.playerIn = false
        var arena_shift: SKAction = SKAction()
        var player_shift: SKAction = SKAction()
        if(movingto == "N"){
            ycoords -= 1
            next_arena = construct_arena(room: current_room.north!, centerx: self.view!.bounds.width/2, centery: 3*self.view!.bounds.height/2, opengates: true)
            //Shifts both player and arenas accordingly
            arena_shift = SKAction.moveBy(x: 0.0, y: -self.view!.bounds.height, duration: 0.8)
            player_shift = SKAction.moveTo(y: self.arena_bounds.minY, duration: 0.8)
            current_room = current_room.north!
            arena["north gate"]!.physicsBody!.categoryBitMask = CollisionType.Blank.rawValue
        }
        if(movingto == "S"){
            ycoords += 1
            next_arena = construct_arena(room: current_room.south!, centerx: self.view!.bounds.width/2, centery: -self.view!.bounds.height/2, opengates: true)
            //Shifts both player and arenas accordingly
            arena_shift = SKAction.moveBy(x: 0.0, y: self.view!.bounds.height, duration: 0.8)
            player_shift = SKAction.moveTo(y: self.arena_bounds.maxY, duration: 0.8)
            current_room = current_room.south!
            arena["south gate"]!.physicsBody!.categoryBitMask = CollisionType.Blank.rawValue
        }
        if(movingto == "W"){
            xcoords -= 1
            next_arena = construct_arena(room: current_room.west!, centerx: self.view!.bounds.width/2 - (5.5*self.view!.bounds.width/10) + (self.view!.bounds.width/132), centery: self.view!.bounds.height/2, opengates: true)
            //Shifts both player and arenas accordingly
            arena_shift = SKAction.moveBy(x: 5.5*self.view!.bounds.width/10 - (self.view!.bounds.width/132), y: 0.0, duration: 0.8)
            player_shift = SKAction.moveTo(x: self.arena_bounds.maxX, duration: 0.8)
            current_room = current_room.west!
            arena["west gate"]!.physicsBody!.categoryBitMask = CollisionType.Blank.rawValue
        }
        if(movingto == "E"){
            xcoords += 1
            next_arena = construct_arena(room: current_room.east!, centerx: self.view!.bounds.width/2 + (5.5*self.view!.bounds.width/10)-(self.view!.bounds.width/132), centery: self.view!.bounds.height/2, opengates: true)
            //Shifts both player and arenas accordingly
            arena_shift = SKAction.moveBy(x: -5.5*self.view!.bounds.width/10 + (self.view!.bounds.width/132), y: 0.0, duration: 0.8)
            player_shift = SKAction.moveTo(x: self.arena_bounds.minX, duration: 0.8)
            current_room = current_room.east!
            arena["east gate"]!.physicsBody!.categoryBitMask = CollisionType.Blank.rawValue
        }
        viewController.map_display.updateMap(scene: self)
         current_room.playerIn = true
        arena_shift.timingMode = .easeInEaseOut
        player_shift.timingMode = .easeInEaseOut
        for (_, part) in arena{
            part.run(arena_shift)
        }
        for (_, part) in next_arena{
            part.run(arena_shift)
        }
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.run{
                for (_, part) in self.arena{
                    part.removeFromParent()
                }
                self.arena = self.next_arena
            },
            SKAction.wait(forDuration: 0.1),
            SKAction.run{
                if(self.current_room.status == "uncleared"){
                    self.run(SKAction.sequence([
                    SKAction.run{self.closeGates()},
                    SKAction.wait(forDuration: 0.3),
                    SKAction.run{self.spawn_enemies()}
                    ]))
                }
            }
            /*for(name, part) in self.next_arena{
                print(name)
                print(part.position)
            }*/
            ]))
            
        PC.run(SKAction.sequence([
            player_shift,
            SKAction.run{self.PC.physicsBody!.categoryBitMask = CollisionType.Player.rawValue},
        ]))
        //print("New coordinates: ",xcoords,",",ycoords)
    }
    
    //Prototype enemy spawning function
    func spawn_enemies(){
        //Spawns target
        let newtarget = SKAction.run{
            //Spawns enemy, immediately runs its behavior
            let enemy = Basic_Enemy(scale: 0.25, game_world: self)
            self.spawn(tospawn: enemy)
        }
        let spawning = SKAction.repeat(newtarget,count: 2)
        self.run(spawning)
    }
    
//Handles contact between sprites
    func didBegin(_ contact: SKPhysicsContact) {
        //Makes sure didBegin isn't being called on a node that no longer exists
        //I'm not sure how a node that no longer exists manages to collide with stuff either
        //But it happens pretty regularly for some reason?
        guard let contactA = contact.bodyA.node
            else {return}
        guard let contactB = contact.bodyB.node
            else {return}
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask{
        //Handles contact between player bullets and enemy
        case CollisionType.Enemy.rawValue | CollisionType.Player_Bullet.rawValue:
            if let bullet = contactA as? Bullet {
                let enemy = contactB as! Enemy
                enemy.damaged(damageValue: bullet.get_damage())
                bullet.impact()
            }
            else {
                let enemy = contactA as! Enemy
                let bullet = contactB as! Bullet
                enemy.damaged(damageValue: bullet.get_damage())
                bullet.impact()
            }
        //Handles contact between enemy bullets and player
        case CollisionType.Player.rawValue | CollisionType.Enemy_Bullet.rawValue:
            if let bullet = contactA as? Bullet {
                let player = contactB as! Player_Character
                player.damaged(damageValue: bullet.get_damage())
                bullet.impact()
            }
            else {
                let player = contactA as! Player_Character
                let bullet = contactB as! Bullet
                player.damaged(damageValue: bullet.get_damage())
                bullet.impact()
            }
            viewController.updateHealth(health: PC.health)
        //Handles contact between bullets and walls 
        case CollisionType.Wall.rawValue | CollisionType.Player_Bullet.rawValue:
            if let bullet = contactA as? Bullet {
                if(!bullet.can_bounce()){
                    bullet.impact()
                } else {
                    bullet.bounced()
                }
            }
            else {
                let bullet = contactB as! Bullet
                if(!bullet.can_bounce()){
                    bullet.impact()
                } else {
                    bullet.bounced()
                }
            }
        case CollisionType.Wall.rawValue | CollisionType.Enemy_Bullet.rawValue:
            if let bullet = contactA as? Bullet {
                if(!bullet.can_bounce()){
                    bullet.impact()
                } else {
                    bullet.bounced()
                }
            }
            else {
                let bullet = contactB as! Bullet
                if(!bullet.can_bounce()){
                    bullet.impact()
                } else {
                    bullet.bounced()
                }
            }
        case CollisionType.Blank.rawValue | CollisionType.Enemy_Bullet.rawValue:
            if let bullet = contactA as? Bullet {
                bullet.impact()
            }
            else {
                let bullet = contactB as! Bullet
                bullet.impact()
            }
        case CollisionType.Blank.rawValue | CollisionType.Player_Bullet.rawValue:
            if let bullet = contactA as? Bullet {
                if(current_room.status == "cleared"){bullet.impact()}
            }
            else {
                let bullet = contactB as! Bullet
                if(current_room.status == "cleared"){bullet.impact()}
            }
        //Triggers passage between rooms upon the player reaching an open gate
        case CollisionType.Gate.rawValue | CollisionType.Player.rawValue:
            if let gate = contactA as? Gate{
                transition_check = gate.direction
            } else {
                let gate = contactB as! Gate
                transition_check = gate.direction
            }
            
        default:
            break
        }
        
    }
    
    
    
}

//Defines a series of contact bitmask variables for collision handling
enum CollisionType : UInt32 {
    case Player = 0x01
    case Enemy = 0x02
    case Player_Bullet = 0x04
    case Enemy_Bullet = 0x08
    case Wall = 0x10
    case Gate = 0x20
    case Blank = 0x40
}



//Old, outdated code I feel too senitmental and/or paranoid to delete
/*

 //Old ship movement function based off of SKActions - really liked to clip through walls!
 /*let newlocation = CGPoint(x: PC.position.x + ship_speedX, y: PC.position.y + ship_speedY)
 let movement = SKAction.move(to: newlocation, duration: 0.1)
 movement.timingMode = .easeOut
 PC.run(movement)
  */
 
//That thing you wrote before learning about 'contains'

var movement_stick_x: CGFloat //Determines joystick location within base bounds
var movement_stick_y: CGFloat
if location.x < movement_base.position.x - stick_length || location.x > movement_base.position.x + stick_length {
    movement_stick_x = movement_base.position.x - move_xDist
} else {
    movement_stick_x = location.x
}
if location.y < movement_base.position.y - stick_length || location.y > movement_base.position.y + stick_length {
    movement_stick_y = movement_base.position.y + move_yDist
} else {
    movement_stick_y = location.y
}
//Sets final joystick position
movement_stick.position = CGPoint(x: movement_stick_x, y: movement_stick_y)


//Other cool path features

let reversepath = followpath.reversed()
let back_n_forth = SKAction.sequence([followpath,reversepath])
red_target!.run(back_n_forth)
let line = SKShapeNode()
line.path = path
line.lineWidth = 2
line.fillColor = SKColor.blue
line.strokeColor = SKColor.red
self.addChild(line)
let encore = SKAction.repeatForever(back_n_forth)
red_target!.run(encore)
 
 */
