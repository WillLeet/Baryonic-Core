//
//  GameViewController.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 1/13/20.
//  Copyright © 2020 William Leet. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var health_label: UILabel!
    var game: GameScene?
    @IBOutlet weak var health_bar: UIImageView!
    @IBOutlet weak var health_status: UILabel!
    var health_graphics: [UIImage] = []
    //let movestick = UIImageView(image: UIImage(named: "Movement stick gui"))
    @IBOutlet weak var movestick_base: UIImageView!
    @IBOutlet weak var shootstick_base: UIImageView!
    @IBOutlet weak var map_display: MapView!
    var ability1_charges: Int = 3
    var ability2_charges: Int = 3
    var ability1_type: String = "BAMF"
    var ability2_type: String = "No Ability"
    
    @IBOutlet weak var ability1_chargeDisplay: UIImageView!
    @IBOutlet weak var ability2_chargeDisplay: UIImageView!
    @IBOutlet weak var ability2_status: UILabel!
    @IBOutlet weak var ability1_label: UILabel!
    @IBOutlet weak var ability2_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.size = view.bounds.size
                scene.scaleMode = .aspectFill
                scene.viewController = self
                // Present the scene
                view.presentScene(scene)
                game = scene
                health_label.text = "HULL INTEGRITY: "
                health_status.text = "NOMINAL"
                health_status.textColor = UIColor(hue: 0.3, saturation: 0.41, brightness: 1, alpha: 1)
                //movestick.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                //self.view.addSubview(movestick)
                

            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        ability1_label.numberOfLines = 2
        ability1_label.text = "B.A.M.F\nCHARGES"
        ability2_label.numberOfLines = 2
        ability2_label.text = ""
        ability2_status.text = "NO CONTINGENCY"
    }
    
    /*
    func updateJoystick(stick: String, x: CGFloat, y: CGFloat){
        if(stick=="move"){
            movestick.frame.origin.x = x-movestick.frame.width/2-movestick_base.frame.width/150
            movestick.frame.origin.y = self.view!.bounds.height-y-movestick.frame.height/2-movestick_base.frame.height/100
        }
    }
    */
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateHealth(health: Int){
        let health_percent: String = "Health "+String(health * 10)+"%"
        //print(health_percent)
        health_bar.image = UIImage(named: health_percent)
        if(health>8){
            health_status.text = "NOMINAL"
            health_status.textColor = UIColor(hue: 0.3, saturation: 0.41, brightness: 1, alpha: 1)
            health_label.text = "HULL INTEGRITY: "
            health_label.textColor = UIColor(red: 0.423529, green: 0.858824, blue: 0.909804, alpha: 1)
        }
        else if(health>6){
            health_status.text = "STABLE"
            health_status.textColor = UIColor(hue: 0.25, saturation: 0.41, brightness: 1, alpha: 1)
        }
        else if(health>4){
            health_status.text = "DAMAGED"
            health_status.textColor = UIColor(hue: 0.2, saturation: 0.41, brightness: 1, alpha: 1)
        }
        else if(health>2){
            health_status.text = "BREACHED"
            health_status.textColor = UIColor(hue: 0.1, saturation: 0.41, brightness: 1, alpha: 1)
        }
        else if(health>0){
            health_status.text = "CRITICAL"
            health_status.textColor = UIColor(hue: 0.0, saturation: 0.41, brightness: 1, alpha: 1)
        } else {
            health_status.text = ""
            health_label.textColor = UIColor(hue: 0.0, saturation: 0.8, brightness: 1, alpha: 1)
            health_label.text = "ERROR\\%-ERR{OR--;;ERR"
        }
    }
    
    func updateCharges(display: UIImageView, type: String, charges: Int){
        if(charges == 0){
            display.image = UIImage(named: "No Ability")
        } else {
            let spritename: String = type + String(charges)
            display.image = UIImage(named: spritename)
        }
    }
    
    @IBAction func ability1(_ sender: Any) {
        if(ability1_charges>0){
            ability1_charges -= 1
            updateCharges(display: ability1_chargeDisplay, type: ability1_type, charges: ability1_charges)
            game!.PC.bamf()
        }
    }
    
    @IBAction func ability2(_ sender: Any) {
        print("Button in progress!")
    }
    
    @IBAction func pause_game(_ sender: Any) {
        game!.isPaused = !game!.isPaused
    }
}
