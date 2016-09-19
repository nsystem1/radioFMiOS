//
//  ProgramCell.swift
//  fm100
//
//  Created by Leonid Angarov on 22/08/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ProgramCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAutor: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var imgPicture: UIImageView!
    
    
    func configureCell(program:Program, anim:Bool) -> UIView {
        
        
        self.lblTitle.text = program.name
        self.lblAutor.text = program.author
        self.lblStart.text = program.start
        self.imgPicture.hidden = !anim  
        /*if( anim ) {
            animation1()
        } else {
            self.layer.removeAllAnimations()
        }*/
        
        return self
    }
    
    func animation1() {
        let r = CAReplicatorLayer()
        r.bounds = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 40.0)
        r.position = CGPoint(x: 80, y: 5)
        //r.position = self.center
        r.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(r)
        
        let bar = CALayer()
        bar.bounds = CGRect(x: 0.0, y: 0.0, width: 6.0, height: 30.0)
        bar.position = CGPoint(x: 10.0, y: 50.0)
        //bar.cornerRadius = 1.0
        bar.backgroundColor = UIColor.yellowColor().CGColor
        
        r.addSublayer(bar)
        
        let move = CABasicAnimation(keyPath: "position.y")
        move.toValue = bar.position.y - 15.0
        move.duration = 0.3
        move.autoreverses = true
        move.repeatCount = Float.infinity
        
        bar.addAnimation(move, forKey: nil)
        
        r.instanceCount = 3
        r.instanceTransform = CATransform3DMakeTranslation(5.0, 0.0, 0.0)
        r.instanceDelay = 0.35
        r.masksToBounds = true

    }
}
