//
//  MapView.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 8/7/20.
//  Copyright © 2020 William Leet. All rights reserved.
//
// A custom UIView that draws the ship's map.

import UIKit

//A simple struct that lets me attach colors to CGRects
struct MapSquare{
    let frame: CGRect!
    var color: CGColor!
}

class MapView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    var display = [MapSquare]()
    
    override func draw( _ frame: CGRect) {
        
        super.draw(frame)
        
        if let context: CGContext = UIGraphicsGetCurrentContext(){
            //Grabs the last rectangle in the set to draw last as the green rectangle denoting player location
            //If no such rectangle exists, there is nothing to draw, and the function returns
            for square in display{
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0);   //this is the transparent color
                context.setStrokeColor(square.color);
                context.fill(square.frame); //Draws the map square
                context.stroke(square.frame);
                context.addRect(square.frame)
            }
        } else {
            //This only triggers is something has gone horribly wrong
            print("Context not found")
            return
        }



    }
    
    public func updateMap(scene: GameScene){
        let w = self.frame.width
        let h = self.frame.height
        var drect: CGRect!
        var dcolor: CGColor!
        display = []
        for x in 0..<scene.level_size{
            for y in 0..<scene.level_size{
                let true_y: Int = abs(y - scene.level_size - 1)
                drect = CGRect(x: CGFloat(x)*w/8 + (h/100), y: CGFloat(true_y-1)*h/8 + (h/100), width: (h / 11), height: (h / 11))
                if(scene.current_level[x][y].playerIn){
                    dcolor = CGColor(red: 0.0, green: 100.0, blue: 0.0, alpha: 1.0)
                    display.append(MapSquare(frame: drect, color: dcolor))
                } else if(scene.current_level[x][y].visited){
                    dcolor = CGColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
                    display.append(MapSquare(frame: drect, color: dcolor))
                } else if(scene.current_level[x][y].seen){
                    dcolor = CGColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.4)
                    display.append(MapSquare(frame: drect, color: dcolor))
                }
            }
        }
        setNeedsDisplay()
    }
}


/*let drect = CGRect(x: (w/50) + CGFloat(i)*w/8, y: (h/100) + CGFloat(j)*h/8, width: (h / 11), height: (h / 11))
let color:UIColor = UIColor.cyan
let bpath:UIBezierPath = UIBezierPath(rect: drect)
color.set()
bpath.stroke()
*/


/*
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
*/
