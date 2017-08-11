//
//  Background.swift
//  Dig to China
//
//  Created by Martin Tang on 7/21/17.
//  Copyright © 2017 Martin Tang. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {
    
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
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        health = 0
        super.init(coder: aDecoder)
    }
}

class GrassBackground: Background {
        
        init(health: CGFloat) {
            let texture = SKTexture(imageNamed: "grassBlock")
            let color = UIColor.clear
            let size = CGSize(width: 50, height: 50)
            
            super.init(texture: texture, color: color, size: size)
            self.health = health

        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    }


class CrustBackground: Background {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(health: CGFloat) {
        let sheet=SpriteSheet(texture: SKTexture(imageNamed: "spritesheet"), rows: 18, columns: 29, spacing: 1, margin: 0)
        let sprite = sheet.textureForColumn(column: 9, row: 10)
        super.init(texture: sprite, color: UIColor.black, size: CGSize(width: 50, height: 50))
        self.health = health
    }
    
}

class MantleBackground: Background {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     init(health: CGFloat) {
        let sheet = SpriteSheet(texture: SKTexture(imageNamed: "spritesheet"), rows: 18, columns: 29, spacing: 1, margin: 0)
        let sprite = sheet.textureForColumn(column: 9, row: 15)
        super.init(texture: sprite, color: UIColor.black, size: CGSize(width: 50, height: 50))
        self.health = health
    }
    
}

class CoreBackground: Background {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(health: CGFloat) {
        let sheet = SpriteSheet(texture: SKTexture(imageNamed: "spritesheet"), rows: 18, columns: 29, spacing: 1, margin: 0)
        let sprite = sheet.textureForColumn(column: 9, row: 10)
        //colorize sprite to red
        //run on actual object when making ground, not on the sprite
        //sprite.runAction(colorize)
        super.init(texture: sprite, color: UIColor.black, size: CGSize(width: 50, height: 50))
        self.health = health
    }
}

//to create the ground




