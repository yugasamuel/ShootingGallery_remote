//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Yuga Samuel on 23/09/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var countdownLabel: SKLabelNode!
    var rifle: SKSpriteNode!
    var crosshair: SKSpriteNode!
    
    var duckTimer: Timer?
    var countdownTimer: Timer?
    
    var gameOverLabel: SKSpriteNode!
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var countdownTime = 0 {
        didSet {
            countdownLabel.text = "Time Left: \(countdownTime)"
        }
    }
    
    var spawnTime = 1.0 {
        didSet {
            duckTimer?.invalidate()
            duckTimer = Timer.scheduledTimer(timeInterval: spawnTime, target: self, selector: #selector(createDuck), userInfo: nil, repeats: true)
        }
    }
    
    let possibleDucks = ["duck_outline_target_brown", "duck_outline_target_white", "duck_outline_yellow"]
    
    override func didMove(to view: SKView) {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(depleteTime), userInfo: nil, repeats: true)
        duckTimer = Timer.scheduledTimer(timeInterval: spawnTime, target: self, selector: #selector(createDuck), userInfo: nil, repeats: true)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 512, y: 555)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = 52
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        countdownLabel = SKLabelNode(fontNamed: "Chalkduster")
        countdownLabel.position = CGPoint(x: 512, y: 500)
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.fontSize = 24
        countdownLabel.zPosition = -9
        addChild(countdownLabel)
        
        rifle = SKSpriteNode(imageNamed: "rifle")
        rifle.position = CGPoint(x: 840, y: 100)
        addChild(rifle)
        
        score = 0
        countdownTime = 60
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 || node.position.x > 1200 {
                node.removeFromParent()
            }
        }

        if countdownTime == 1 {
            isGameOver = true
        }
    }
    
    @objc func depleteTime() {
        countdownTime-=1
        if isGameOver {
            duckTimer?.invalidate()
            countdownTimer?.invalidate()
            gameOverLabel = SKSpriteNode(imageNamed: "gameOver")
            gameOverLabel.position = CGPoint(x: 512, y: 384)
            gameOverLabel.zPosition = 1
            gameOverLabel.name = "game_over_label"
            addChild(gameOverLabel)
            
            countdownLabel.text = "Tap any where to play again"
            
            for node in self.children {
                if node.name == "duck_yellow" || node.name == "duck_brown" || node.name == "duck_white" {
                    node.removeFromParent()
                }
            }
        }
    }

    @objc func createDuck() {
        let position: CGPoint!
        let zPosition: CGFloat!
        let xScale: CGFloat!
        let yScale: CGFloat!
        var velocity: CGVector!
        var name: String!
        
        let row = Int.random(in: 1...3)
        if row == 1 {
            position = CGPoint(x: -75, y: 195)
            velocity = CGVector(dx: 300, dy: 0)
            zPosition = -4
        } else if row == 2 {
            position = CGPoint(x: 1099, y: 325)
            velocity = CGVector(dx: -300, dy: 0)
            zPosition = -6
        } else {
            position = CGPoint(x: -75, y: 450)
            velocity = CGVector(dx: 300, dy: 0)
            zPosition = -8
        }
        
        let size = Int.random(in: 1...5)
        if size == 1 {
            if row == 2 {
                xScale = -0.7
                velocity.dx -= 85
            } else {
                xScale = 0.7
                velocity.dx += 85
            }
            yScale = 0.7
        } else {
            if row == 2 {
                xScale = -1
            } else {
                xScale = 1
            }
            yScale = 1
        }
        
        guard let duck = possibleDucks.randomElement() else { return }
        
        if duck == "duck_outline_target_brown" {
            name = "duck_brown"
        } else if duck == "duck_outline_target_white" {
            name = "duck_white"
        } else {
            name = "duck_yellow"
        }
        
        if size == 1 {
            name += "_small"
        }
        
        let sprite = SKSpriteNode(imageNamed: duck)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.position = position
        sprite.zPosition = zPosition
        sprite.xScale = xScale
        sprite.yScale = yScale
        sprite.name = name
        sprite.physicsBody?.velocity = velocity
        sprite.physicsBody?.categoryBitMask = 0
        
        spawnTime *= 0.991
        
        addChild(sprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if isGameOver && location == location {
            for node in self.children {
                if node.name == "game_over_label" {
                    duckTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createDuck), userInfo: nil, repeats: true)
                    countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(depleteTime), userInfo: nil, repeats: true)
                    score = 0
                    countdownTime = 60
                    isGameOver = false
                    node.removeFromParent()
                }
            }
            
        } else {
            let node = touchedNodes.first(where: { $0.name == "duck_white" || $0.name == "duck_brown" || $0.name == "duck_yellow" || $0.name == "duck_white_small" || $0.name == "duck_brown_small" || $0.name == "duck_yellow_small" })
            
            if node?.name == "duck_yellow" || node?.name == "duck_yellow_small" {
                score -= 5
            } else if node?.name == "duck_brown" || node?.name == "duck_white" {
                score += 1
            } else if node?.name == "duck_brown_small" || node?.name == "duck_white_small" {
                score += 2
            }
            
            node?.removeFromParent()
            
            let crosshair = SKSpriteNode(imageNamed: "crosshair_white_large")
            crosshair.position = location
            addChild(crosshair)
            
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.run { crosshair.removeFromParent() }
            crosshair.run(SKAction.sequence([fade, remove]))
            
            if let gunFire = SKEmitterNode(fileNamed: "FireParticle") {
                gunFire.position = CGPoint(x: 755, y: 250)
                addChild(gunFire)
                
                let fade = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.run { gunFire.removeFromParent() }
                
                gunFire.run(SKAction.sequence([fade, remove]))
            }
            
            run(SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false))
        }
    }
}


