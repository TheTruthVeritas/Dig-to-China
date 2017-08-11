//
//  CreditScreen.swift
//  Dig to China
//
//  Created by Martin Tang on 8/9/17.
//  Copyright © 2017 Martin Tang. All rights reserved.
//

import SpriteKit

class CreditScreen: SKScene {
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        /* Set UI connections */
    }
    
    func loadGame() {
        guard let skView = self.view as SKView! else {
            return
        }
        
        guard let scene = GameScene(fileNamed: "GameScene") else {
            return
        }
        scene.scaleMode = .aspectFit
        skView.showsPhysics = true
        skView.showsDrawCount = false
        skView.showsFPS = false
        skView.presentScene(scene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        loadGame()
    }
    
}
