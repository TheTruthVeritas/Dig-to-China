//
//  GameScene.swift
//  Dig to China
//
//  Created by Martin Tang on 7/13/17.
//  Copyright © 2017 Martin Tang. All rights reserved.
//

import SpriteKit

import AVFoundation

enum GameState {
    case title, playing, menu, digging, dead
}

enum Direction {
    case up, down, left, right
}

class GameScene: SKScene {
    
    var ground: [[Background?]] = Array(repeating: Array(repeating: nil, count: 1406), count: 50)
    var goldGrid: [[Gold?]] = Array(repeating: Array(repeating: nil, count: 1401), count: 50)
    var player: SKReferenceNode!
    var shovel: SKSpriteNode!
    var character: SKSpriteNode!
    var dirtLayer: SKNode!
    var diggingEffect: AVAudioPlayer!
    var restartButton: MSButtonNode!
    var creditButton: MSButtonNode!
    var staminaBar: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var upgradeInfo1: SKLabelNode!
    var upgradeInfo2: SKLabelNode!
    var upgradeInfo3: SKLabelNode!
    var upgradeIcon: SKSpriteNode!
    var upgradeBox: SKSpriteNode!
    var cameraTarget: SKReferenceNode?
    var moneyLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode! {
        didSet {
            if state != .dead {
                gameOverLabel.isHidden = true
            }
        }
    }
    var state: GameState = .title
    var moneyUntilUpgrade: SKLabelNode!
    var shovelDamage: CGFloat = 0.0
    var stamina: CGFloat = 1.0 {
        didSet {
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            staminaBar.xScale = stamina
        }
    }
    var money: Int = 0 {
        didSet {
            if money >= 1000000 {
                moneyLabel?.text = "\(Int(money/1000000)) M"
            } else if money >= 10000 {
                moneyLabel?.text = "\(Int(money/1000)) K"
            } else {
            moneyLabel?.text = String(describing: money)
            }
        }
    }
    
    var untilUpgrade: Int = 500
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        restartButton = self.childNode(withName: "//restartButton") as! MSButtonNode
        restartButton.selectedHandler = {
            let skView = self.view as SKView!
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene?.money = self.money
            
            scene?.scaleMode = .aspectFit
            skView?.presentScene(scene)
        }

        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        staminaBar = childNode(withName: "//staminaBar") as! SKSpriteNode
        player = childNode(withName: "//player") as! SKReferenceNode
        shovel = childNode(withName: "//shovel") as! SKSpriteNode
        character = childNode(withName: "//character") as! SKSpriteNode
        moneyLabel = childNode(withName: "//moneyLabel") as! SKLabelNode
        moneyLabel?.text = String(describing: money)
        upgradeInfo1 = childNode(withName: "//upgradeInfo1") as! SKLabelNode
        upgradeInfo1.isHidden = true
        upgradeInfo2 = childNode(withName: "//upgradeInfo2") as! SKLabelNode
        upgradeInfo2.isHidden = true
        upgradeInfo3 = childNode(withName: "//upgradeInfo3") as! SKLabelNode
        upgradeInfo3.isHidden = true
        upgradeBox = childNode(withName: "//upgradeBox") as! SKSpriteNode
        upgradeBox.isHidden = true
        upgradeIcon = childNode(withName: "//upgradeIcon") as! SKSpriteNode
        upgradeIcon.isHidden = true
        gameOverLabel = childNode(withName: "//gameOverLabel") as! SKLabelNode
        moneyUntilUpgrade = childNode(withName: "//moneyUntilUpgrade") as! SKLabelNode
        dirtLayer = self.childNode(withName: "//dirtLayer")
        creditButton = self.childNode(withName: "//creditButton") as! MSButtonNode
        creditButton.selectedHandler = {
            let skView = self.view as SKView!
            let scene = CreditScreen(fileNamed:"CreditScreen") as CreditScreen!
            scene?.scaleMode = .aspectFit
            skView?.presentScene(scene)
        }
        createGrid()
        spawnGold()
        generateGrid()
        createGold()
        cameraTarget = player
        restartButton.state = .msButtonNodeStateHidden
         let defaults = UserDefaults.standard
        let savedMoney = defaults.integer(forKey: "money")
        let savedDamage: Int = defaults.integer(forKey: "shovelDamage")
        money = savedMoney
        shovelDamage = CGFloat(savedDamage)
        
    }
    
    func scrollDirt() {
        dirtLayer.position.x = cameraNode.position.x
        dirtLayer.position.y = cameraNode.position.y
        for Dirt in dirtLayer.children as! [SKSpriteNode] {
            let dirtPosition = dirtLayer.convert(Dirt.position, to: self)
            
            if dirtPosition.x <= -Dirt.size.width / 2 {
                let newPosition = CGPoint(x: (self.size.width / 2) + Dirt.size.width, y: dirtPosition.y)
                Dirt.position = self.convert(newPosition, to: dirtLayer)
            }
            if -dirtPosition.x >= Dirt.size.width / 2 {
                let newPosition = CGPoint(x: (self.size.width / 2) - Dirt.size.width, y: dirtPosition.y)
                Dirt.position = self.convert(newPosition, to: dirtLayer)
            }
        }
    }
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let targetY = cameraTarget.position.y
        let y = clamp(value: targetY, lower: -69850, upper: 568)
        let x = clamp(value: targetX, lower: -400, upper: 1200)
        cameraNode.position.x = x
        cameraNode.position.y = y
    }
    
    func spawnGold() {
        for yCrust in 1..<201 {
            for xCrust in 0..<50 {
                if randomNumber(inRange: 1...100) <= 10 {
                    let crustGold = CrustGold(health: 1, goldAmount: CGFloat(100 + 2 * yCrust))
                    crustGold.position.y = CGFloat(150 - yCrust * 50)
                    crustGold.position.x = CGFloat(-550 + xCrust * 50)
                    crustGold.zPosition = 5
                    addChild(crustGold)
                    goldGrid[xCrust][yCrust] = crustGold
                    ground[xCrust][yCrust]?.removeFromParent()
                    ground[xCrust][yCrust] = nil
                }
            }
        }
        
        for yMantle in 0..<800 {
            for xMantle in 0..<50 {
                if randomNumber(inRange: 1...100) <= 10 {
                    let mantleGold = MantleGold(health: 1, goldAmount: CGFloat(600 + 3 * yMantle))
                    mantleGold.position.y = CGFloat(-9850 - yMantle * 50)
                    mantleGold.position.x = CGFloat(-550 + xMantle * 50)
                    mantleGold.zPosition = 5
                    addChild(mantleGold)
                    goldGrid[xMantle][yMantle+200] = mantleGold
                    ground[xMantle][yMantle+200]?.removeFromParent()
                    ground[xMantle][yMantle+200] = nil
                }
            }
        }
        
        for yCore in 0..<400 {
            for xCore in 0..<50 {
                if randomNumber(inRange: 1...100) <= 10 {
                    let coreGold = CoreGold(health: 1, goldAmount: CGFloat(5000 + 5 * yCore))
                    coreGold.position.y = CGFloat(-49850 - yCore * 50)
                    coreGold.position.x = CGFloat(-550 + xCore * 50)
                    coreGold.zPosition = 5
                    addChild(coreGold)
                    goldGrid[xCore][yCore+1000] = coreGold
                    ground[xCore][yCore+1000]?.removeFromParent()
                    ground[xCore][yCore+1000] = nil
                }
            }
        }
        
    }
    
    func generateGrid() {
        for y in 0..<1406 {
            for x in 0..<50 {
                let dirtPiece = ground[x][y]
                if dirtPiece != nil {
                let dirtPosition = self.convert(dirtPiece!.position, to: cameraNode)
                if dirtPosition.x >= -200 && dirtPosition.x <= 200 && dirtPosition.y >= -350 && dirtPosition.y <= 350 {
                    if dirtPiece?.parent == nil {
                    addChild(dirtPiece!)
                    }
                } else if dirtPiece?.parent != nil {
                    dirtPiece?.removeFromParent()
                }
            }
            }
        }
    }
    
    func createGold() {
        for y in 0..<1401 {
            for x in 0..<50 {
                let goldPiece = goldGrid[x][y]
                if goldPiece != nil {
                let goldPosition = self.convert((goldPiece?.position)!, to: cameraNode)
                if goldPosition.x >= -200 && goldPosition.x <= 200 && goldPosition.y >= -350 && goldPosition.y <= 350 {
                    if goldPiece?.parent == nil {
                        addChild(goldPiece!)
                    }
                } else if goldPiece?.parent != nil {
                    goldPiece?.removeFromParent()
                }
            }
            }
        }
    }
    
    func createGrid() {
        //creating crust layer
        for x in 0..<50 {
            let grassObject = GrassBackground(health: 1)
            grassObject.position.y = 150
            grassObject.position.x = CGFloat(-550 + x * 50)
            grassObject.zPosition = 6
            ground[x][0] = grassObject
        }
        
        for yCrust in 0..<200 {
            for xCrust in 0..<50 {
                let crustObject = CrustBackground(health: CGFloat(100 + yCrust * 2))
                crustObject.position.y = CGFloat(100 - yCrust * 50)
                crustObject.position.x = CGFloat(-550 + xCrust * 50)
                crustObject.zPosition = 6
                ground[xCrust][yCrust+1] = crustObject
            }
        }
        //creating mantle
        for yMantle in 0..<800 {
            for xMantle in 0..<50 {
                let mantleObject = MantleBackground(health: CGFloat(750 + yMantle * 3))
                mantleObject.position.y = CGFloat(-9900 - yMantle * 50)
                mantleObject.position.x = CGFloat(-550 + xMantle * 50)
                mantleObject.zPosition = 6
                ground[xMantle][yMantle+201] = mantleObject
            }
        }
        
        for yCore in 0..<400 {
            for xCore in 0..<50 {
                let coreObject = CoreBackground(health: CGFloat(5000 + yCore * 10))
                let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.1)
                coreObject.run(colorize)
                coreObject.position.y = CGFloat(-49900 - yCore * 50)
                coreObject.position.x = CGFloat(-550 + xCore * 50)
                coreObject.zPosition = 6
                ground[xCore][yCore+1001] = coreObject
            }
        }
        
        for yEnd in 0..<5 {
            for xEnd in 0..<50 {
                let endObject = CrustBackground(health: 1)
                let colorize = SKAction.colorize(with: .black, colorBlendFactor: 1, duration: 0.1)
                endObject.run(colorize)
                endObject.position.y = CGFloat(-69900 - yEnd * 50)
                endObject.position.x = CGFloat(-550 + xEnd * 50)
                endObject.zPosition = 6
                addChild(endObject)
                ground[xEnd][yEnd+1401] = endObject
            }
        }
    }
    
    
    
    func Tap(direction: Direction) {
        
        hideUpgrades()
        if money >= 500000 {
            stamina -= 0.00025
        } else if money >= 125000 {
            stamina -= 0.0005
        } else if money >= 75000 {
            stamina -= 0.000625
        } else if money >= 35000 {
            stamina -= 0.00125
        } else if money >= 10000 {
            stamina -= 0.0025
        } else if money >= 2000 {
                stamina -= 0.005
        }
        
        else { stamina -= 0.01 }
        if direction == .up {
            let NodeAtPoint = atPoint(CGPoint(x: player.position.x, y: player.position.y + 50))
            if NodeAtPoint is Background {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col = abs(Int(location.y - 150) / 50)
                if let piece = ground[row][col] {
                    piece.health = piece.health - shovelDamage
                    shovel.run(SKAction.init(named: "Digging")!)
                }
            } else if NodeAtPoint is Gold {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col = abs(Int(location.y - 150) / 50)
                if let piece = goldGrid[row][col] {
                    money += piece.goldAmount
                    piece.health -= shovelDamage
                }
            }
        }
        else if direction == .down {
            let NodeAtPoint = atPoint(CGPoint(x: player.position.x, y: player.position.y - 50))
            if NodeAtPoint is Background {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col  = abs(Int(location.y - 150) / 50)
                
                if let piece = ground[row][col] {
                    piece.health = piece.health - shovelDamage
                    shovel.run(SKAction.init(named: "Digging")!)
                }
            } else if NodeAtPoint is Gold {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col  = abs(Int(location.y - 150) / 50)
                if let piece = goldGrid[row][col] {
                    money += piece.goldAmount
                    piece.health -= shovelDamage
                }
            } else {
                player.position.y -= 50
                generateGrid()
                createGold()
            }
        }
        else if direction == .left {
            player.xScale = -1
            let NodeAtPoint = atPoint(CGPoint(x: player.position.x - 50, y: player.position.y))
            if NodeAtPoint is Background {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col  = abs(Int(location.y - 150) / 50)
                
                if let piece = ground[row][col] {
                    piece.health = piece.health - shovelDamage
                    shovel.run(SKAction.init(named: "Digging")!)
                }
            } else if NodeAtPoint is Gold {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col  = abs(Int(location.y - 150) / 50)
                if let piece = goldGrid[row][col] {
                    money += piece.goldAmount
                    piece.health -= shovelDamage
                }
            } else {
                character.run(SKAction.init(named: "moving")!)
                player.position.x -= 50
                generateGrid()
                createGold()
            }
        }
        else if direction == .right {
            player.xScale = 1
            let NodeAtPoint = atPoint(CGPoint(x: player.position.x + 50, y: player.position.y))
            if NodeAtPoint is Background {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col  = abs(Int(location.y - 150) / 50)
                if let piece = ground[row][col] {
                    piece.health = piece.health - shovelDamage
                    shovel.run(SKAction.init(named: "Digging")!)
                }
            } else if NodeAtPoint is Gold {
                let path = Bundle.main.path(forResource: "digging.wav", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let sound = try AVAudioPlayer(contentsOf: url)
                    diggingEffect = sound
                    sound.volume = 0.3
                    sound.play()
                } catch {
                    // couldn't load file :(
                }
                let location = NodeAtPoint.position
                let row = Int(550 + location.x) / 50
                let col  = abs(Int(location.y - 150) / 50)
                if let piece = goldGrid[row][col] {
                    money += piece.goldAmount
                    piece.health -= shovelDamage
                }
            } else {
                character.run(SKAction.init(named: "moving")!)
                player.position.x += 50
                generateGrid()
                createGold()
            }
        }
        loadVictory()
    }
    
    func hideUpgrades() {
        upgradeIcon.isHidden = true
        upgradeBox.isHidden = true
        upgradeInfo1.isHidden = true
        upgradeInfo2.isHidden = true
        upgradeInfo3.isHidden = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .dead {return}
        var direction: Direction
        let touch = touches.first!
        let location = touch.location(in: self)
        let yDiff = location.y - player.position.y
        let xDiff = location.x - player.position.x
       if abs(yDiff) > abs(1.775 * xDiff) && yDiff > 0 {
            direction = .up
            
        } else if abs(yDiff) < abs(xDiff * 1.775) && xDiff > 0 {
            direction = .right
        } else if abs(yDiff) > abs(1.775 * xDiff) && yDiff < 0 {
            direction = .down
        } else {
            direction = .left
        }
    
        Tap(direction: direction)
        
    }
    
    func checkMoney() {
        let shovel = ShovelDamage()
        var newShovelDamage: CGFloat = 0
        if money >= 500000 {
            newShovelDamage = shovel.nineteenth
        } else if money >= 400000 {
            newShovelDamage = shovel.eighteenth
        } else if money >= 325000 {
           newShovelDamage = shovel.seventeenth
        } else if money >= 250000 {
            newShovelDamage = shovel.sixteenth
        } else if money >= 200000 {
            newShovelDamage = shovel.fifteenth
        } else if money >= 150000 {
            newShovelDamage = shovel.fourteenth
        } else if money >= 125000 {
            newShovelDamage = shovel.thirteenth
        } else if money >= 100000 {
            newShovelDamage = shovel.twelfth
        } else if money >= 75000 {
            newShovelDamage = shovel.eleventh
        } else if money >= 60000 {
            newShovelDamage = shovel.tenth
        } else if money >= 50000 {
            newShovelDamage = shovel.ninth
        } else if money >= 35000 {
            newShovelDamage = shovel.eigth
        } else if money >= 27500 {
            newShovelDamage = shovel.seventh
        } else if money >= 20000 {
            newShovelDamage = shovel.sixth
        } else if money >= 10000 {
            newShovelDamage = shovel.fifth
        } else if money >= 5000 {
            newShovelDamage = shovel.fourth
        } else if money >= 2000 {
            newShovelDamage = shovel.third
        } else if money >= 1000 {
            newShovelDamage = shovel.second
        } else if money >= 500 {
            newShovelDamage = shovel.first
        } else if money >= 0 {
            newShovelDamage = shovel.start
        }
        
        if (newShovelDamage != shovelDamage) {
            shovelDamage = newShovelDamage
            upgradeIcon.isHidden = false
            upgradeBox.isHidden = false
            upgradeInfo1.isHidden = false
            upgradeInfo2.isHidden = false
            upgradeInfo3.isHidden = false
            switch shovelDamage {
            case shovel.first:
            upgradeInfo1?.text = "Damage+50!"
            upgradeInfo2?.text = "The head is slightly more"
            upgradeInfo3?.text = "polished than your basic shovel."
            case shovel.second:
                upgradeInfo1?.text = "Damage+50!"
                upgradeInfo2?.text = "The handle is made with only"
                upgradeInfo3?.text = "the highest quality wood."
            case shovel.third:
                upgradeInfo1?.text = "Damage+50 and twice the stamina!"
                upgradeInfo2?.text = "Better grips that"
                upgradeInfo3?.text = "let you dig longer."
            case shovel.fourth:
                upgradeInfo1?.text = "Damage + 75!"
                upgradeInfo2?.text = "The latest in"
                upgradeInfo3?.text = "shovel design."
            case shovel.fifth:
                upgradeInfo1?.text = "Damage + 75 and twice the stamina!"
                upgradeInfo2?.text = "This wind powered shovel"
                upgradeInfo3?.text = "makes digging a breeze!"
            case shovel.sixth:
                upgradeInfo1?.text = "Damage + 75!"
                upgradeInfo2?.text = "Folded over a"
                upgradeInfo3?.text = "thousand times!"
            case shovel.seventh:
                upgradeInfo1?.text = "Damage + 75!"
                upgradeInfo2?.text = "I say it's better than the last one,"
                upgradeInfo3?.text = "but there's really no difference."
            case shovel.eigth:
                upgradeInfo1?.text = "Damage + 100 and twice the stamina!"
                upgradeInfo2?.text = "Pumps out inspirational music"
                upgradeInfo3?.text = "that keeps you motivated."
            case shovel.ninth:
                upgradeInfo1?.text = "Damage + 100!"
                upgradeInfo2?.text = "The head is made of steel."
                upgradeInfo3?.text = "Steel your resolve!"
            case shovel.tenth:
                upgradeInfo1?.text = "Damage + 100!"
                upgradeInfo2?.text = "It costs a lot, therefore"
                upgradeInfo3?.text = "it's strong, right?"
            case shovel.eleventh:
                upgradeInfo1?.text = "Damage + 200 and twice the stamina!"
                upgradeInfo2?.text = "The shovel is"
                upgradeInfo3?.text = "slightly longer."
            case shovel.twelfth:
                upgradeInfo1?.text = "Damage + 300!"
                upgradeInfo2?.text = "It's really shiny."
                upgradeInfo3?.text = ""
            case shovel.thirteenth:
                upgradeInfo1?.text = "Damage + 200 and twice the stamina!"
                upgradeInfo2?.text = "This shovel is EXTREME!"
                upgradeInfo3?.text = ""
            case shovel.fourteenth:
                upgradeInfo1?.text = "Damage + 500!"
                upgradeInfo2?.text = "Blessed by the gods!"
                upgradeInfo3?.text = ""
            case shovel.fifteenth:
                upgradeInfo1?.text = "Damage + 750!"
                upgradeInfo2?.text = "Infused with the power of"
                upgradeInfo3?.text = "dirt. Stronger than it sounds."
            case shovel.sixteenth:
                upgradeInfo1?.text = "Damage + 750!"
                upgradeInfo2?.text = "Streamlined for maximum efficiency!"
                upgradeInfo3?.text = ""
            case shovel.seventeenth:
                upgradeInfo1?.text = "Damage + 1000!"
                upgradeInfo2?.text = "Said to be able to"
                upgradeInfo3?.text = "pierce the heavens."
            case shovel.eighteenth:
                upgradeInfo1?.text = "Damage + 1500!"
                upgradeInfo2?.text = "It destroys anything it touches."
                upgradeInfo3?.text = ""
            case shovel.nineteenth:
                upgradeInfo1?.text = "Damage + 3000 and twice the stamina!"
                upgradeInfo2?.text = "Is essentially the first shovel,"
                upgradeInfo3?.text = "but on a higher plane of existence."
            default:
                upgradeInfo1?.text = "Damage = 50."
                upgradeInfo2?.text = "The basic shovel."
                upgradeInfo3?.text = ""
            }
        }
        
        switch shovelDamage {
        case 50:
            moneyUntilUpgrade?.text = String(describing: 500 - money)
        case 100:
            moneyUntilUpgrade?.text = String(describing: 1000 - money)
        case 150:
            moneyUntilUpgrade?.text = String(describing: 2000 - money)
        case 200:
            moneyUntilUpgrade?.text = String(describing: 5000 - money)
        case 275:
            moneyUntilUpgrade?.text = String(describing: 10000 - money)
        case 350:
            if (20000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((20000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 20000 - money)
            }
        case 425:
            if (27500 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((27500 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 27500 - money)
            }
        case 500:
            if (35000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((35000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 35000 - money)
            }
        case 600:
            if (50000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((50000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 50000 - money)
            }
        case 700:
            if (60000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((60000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 60000 - money)
            }
        case 800:
            if (75000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((75000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 75000 - money)
            }
        case 1000:
            if (100000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((35000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 100000 - money)
            }
        case 1300:
            if (125000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((125000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 125000 - money)
            }
        case 1500:
            if (150000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((150000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 150000 - money)
            }
        case 2000:
            if (150000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((150000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 175000 - money)
            }
        case 2750:
            if (200000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((35000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 200000 - money)
            }
        case 3500:
            if (250000 - money) >= 10000 {
                moneyUntilUpgrade?.text = "\(Int((250000 - money) / 1000)) K"
            } else {
            moneyUntilUpgrade?.text = String(describing: 250000 - money)
            }
        default:
            moneyUntilUpgrade?.text = "N/A"
        }
        
    }
    
    
    func loadVictory() {
        for x in 0..<50 {
            if ground[x][1405] == nil {
                let skView = self.view as SKView!
                let scene = VictoryScreen(fileNamed:"VictoryScreen") as VictoryScreen!
                scene?.scaleMode = .aspectFit
                skView?.presentScene(scene)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if state == .dead {
            gameOverLabel.isHidden = false
            restartButton.state = .msButtonNodeStateActive
        }
        moveCamera()
        
        if stamina <= 0 {
            //replace values with gold and shovelDamage
            let defaults = UserDefaults.standard
            defaults.set(money, forKey: "money")
            defaults.set(shovelDamage, forKey: "shovelDamage")
            
            self.state = .dead
        }
        checkMoney()
        scrollDirt()
        
            }
    
    func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = (range.upperBound - range.lowerBound + 1).toIntMax()
        let value = arc4random().toIntMax() % length + range.lowerBound.toIntMax()
        return T(value)
    }

}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}
