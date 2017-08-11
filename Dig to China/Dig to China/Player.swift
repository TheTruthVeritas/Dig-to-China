//
//  Player.swift
//  Dig to China
//
//  Created by Martin Tang on 7/17/17.
//  Copyright © 2017 Martin Tang. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    var direction: Direction = .right {
        didSet {
            if direction == .right {
                xScale = 1
            } else if direction == .left {
                xScale = -1
            }
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
