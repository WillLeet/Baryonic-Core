//
//  MapView.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 8/7/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
// A custom UIView that draws the ship's map.

import UIKit

class MapView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    var level: [[Room]]!
    var levelsize: Int!
    var x: Int!
    var y: Int!
    var display = [CGRect]()
    var flagRemoval = false
    
    override func draw( _ frame: CGRect) {
        
        super.draw(frame)
        
        if let context: CGContext = UIGraphicsGetCurrentContext(){
            //Grabs the last rectangle in the set to draw last as the green rectangle denoting player location
            //If no such rectangle exists, there is nothing to draw, and the function returns
            guard let currentrect = display.popLast() else {return}
            for drect in display{
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0);   //this is the transparent color
                context.setStrokeColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0);
            context.fill(drect); //Draws the map square
            context.stroke(drect);
            context.addRect(drect)
            }
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0);
            context.setStrokeColor(red: 0.0, green: 100.0, blue: 0.0, alpha: 1.0);
            context.fill(currentrect);
            context.stroke(currentrect);
            context.addRect(currentrect)
            display.append(currentrect)
        } else {
            //This only triggers is something has gone horribly wrong
            print("Context not found")
            return
        }



    }
    
    public func updateMap(scene: GameScene){
        if(flagRemoval){
            flagRemoval = false
            display.removeLast()
        }
        x = scene.xcoords
        y = scene.ycoords
        //print(x!,y!)
        let w = self.frame.width
        let h = self.frame.height
        let drect = CGRect(x: CGFloat(x)*w/8 + (h/100), y: CGFloat(y-1)*h/8 + (h/100), width: (h / 11), height: (h / 11))
        display.append(drect)
        setNeedsDisplay()
        //Flags the green rectangle dictating player location for removal from the display set if the player has already seen the room,
        //since this would mean that a rectangle for the room already exists, and that the green rectangle is redundant.
        //This prevents a graphical glitch where a frequently-visited room is repeatedly drawn and given a "bolded" effect.
        if(scene.current_room.seen){
            flagRemoval = true
        }
    }
}


/*let drect = CGRect(x: (w/50) + CGFloat(i)*w/8, y: (h/100) + CGFloat(j)*h/8, width: (h / 11), height: (h / 11))
let color:UIColor = UIColor.cyan
let bpath:UIBezierPath = UIBezierPath(rect: drect)
color.set()
bpath.stroke()
*/
