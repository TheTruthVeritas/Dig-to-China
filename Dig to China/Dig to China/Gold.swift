//
//  Gold.swift
//  Dig to China
//
//  Created by Martin Tang on 7/27/17.
//  Copyright © 2017 Martin Tang. All rights reserved.
//

import SpriteKit

class Gold: SKSpriteNode {
    
    var goldAmount: Int
    
    var health: CGFloat {
        didSet {
            if health <= 0 {
                self.isHidden = true
            }
        }
    }
    
    var sprite: SKTexture?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        health = 0
        goldAmount = 0
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        goldAmount = 0
        health = 0
        super.init(coder: aDecoder)
    }
}

class CrustGold: Gold {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(health: CGFloat, goldAmount: CGFloat) {
        let sheet = SpriteSheet(texture: SKTexture(imageNamed: "spritesheet"), rows: 18, columns: 29, spacing: 1, margin: 0)
        let sprite = sheet.textureForColumn(column: 13, row: 5)
        super.init(texture: sprite, color: UIColor.black, size: CGSize(width: 50, height: 50))
        self.goldAmount = Int(goldAmount)
        self.health = health
    }
}

class MantleGold: Gold {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(health: CGFloat, goldAmount: CGFloat) {
        let sheet = SpriteSheet(texture: SKTexture(imageNamed: "spritesheet"), rows: 18, columns: 29, spacing: 1, margin: 0)
        let sprite = sheet.textureForColumn(column: 11, row: 4)
        super.init(texture: sprite, color: UIColor.black, size: CGSize(width: 50, height: 50))
        self.goldAmount = Int(goldAmount)
        self.health = health
    }
}

class CoreGold: Gold {
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(health: CGFloat, goldAmount: CGFloat) {
        let sheet = SpriteSheet(texture: SKTexture(imageNamed: "spritesheet"), rows: 18, columns: 29, spacing: 1, margin: 0)
        let sprite = sheet.textureForColumn(column: 12, row: 6)
        super.init(texture: sprite, color: UIColor.black, size: CGSize(width: 50, height: 50))
        self.goldAmount = Int(goldAmount)
        self.health = health
    }
}
