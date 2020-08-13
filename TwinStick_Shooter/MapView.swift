//
//  MapView.swift
//  TwinStick_Shooter
//
//  Created by William Leet on 8/7/20.
//  Copyright © 2020 William Leet. All rights reserved.
//

import UIKit

class MapView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    var level: [[Room]]!
    var levelsize: Int!
    var x: Int!
    var y: Int!
    var display = [CGRect]()
    
    override func draw( _ frame: CGRect) {
        
        super.draw(frame)
        
        if let context: CGContext = UIGraphicsGetCurrentContext(){
            //UIGraphicsPopContext()
            guard let currentrect = display.popLast() else {return}
            for drect in display{
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0);   //this is the transparent color
            context.setStrokeColor(red: 0.0, green: 0.0, blue: 100.0, alpha: 1.0);
            context.fill(drect);
            context.stroke(drect);    //this will draw the border
            context.addRect(drect)
            }
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0);   //this is the transparent color
            context.setStrokeColor(red: 0.0, green: 100.0, blue: 0.0, alpha: 1.0);
            context.fill(currentrect);
            context.stroke(currentrect);    //this will draw the border
            context.addRect(currentrect)
            display.append(currentrect)
            UIGraphicsPushContext(context)
        } else {
            print("Context not found")
            return
        }



    }
    
    public func updateMap(scene: GameScene){
        level = scene.current_level
        levelsize = scene.level_size
        x = scene.xcoords
        y = scene.ycoords
        print(x!,y!)
        let w = self.frame.width
        let h = self.frame.height
        let drect = CGRect(x: CGFloat(x)*w/8, y: CGFloat(y-1)*h/8 + (h/100), width: (h / 11), height: (h / 11))
        display.append(drect)
        setNeedsDisplay()
    }
}


/*let drect = CGRect(x: (w/50) + CGFloat(i)*w/8, y: (h/100) + CGFloat(j)*h/8, width: (h / 11), height: (h / 11))
let color:UIColor = UIColor.cyan
let bpath:UIBezierPath = UIBezierPath(rect: drect)
color.set()
bpath.stroke()
*/
