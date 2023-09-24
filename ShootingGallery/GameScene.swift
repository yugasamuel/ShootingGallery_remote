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
    var timerLabel: SKLabelNode!
    var rifle: SKSpriteNode!
    var crosshair: SKSpriteNode!
    
    var gameTimer: Timer?
    
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var timer = 0 {
        didSet {
            timerLabel.text = "Time Left: \(timer)"
        }
    }
    
    let possibleDucks = ["duck_outline_target_brown", "duck_outline_target_white", "duck_outline_yellow"]
    
    override func didMove(to view: SKView) {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(createDuck), userInfo: nil, repeats: true)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 512, y: 555)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = 52
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.position = CGPoint(x: 512, y: 500)
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.fontSize = 24
        timerLabel.zPosition = 1
        addChild(timerLabel)
        
        rifle = SKSpriteNode(imageNamed: "rifle")
        rifle.position = CGPoint(x: 840, y: 100)
        addChild(rifle)
        
        score = 0
        timer = 60
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 || node.position.x > 1200 {
                node.removeFromParent()
            }
        }

        if timer == 1 {
            isGameOver = true
        }
    }

    @objc func createDuck() {
        if isGameOver {
            gameTimer?.invalidate()
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            return
        }
        
        let position: CGPoint!
        let zPosition: CGFloat!
        let velocity: CGVector!
        let xScale: CGFloat!
        let name: String!
        
        let row = Int.random(in: 1...3)
        if row == 1 {
            position = CGPoint(x: -75, y: 200)
            velocity = CGVector(dx: 300, dy: 0)
            zPosition = -4
            xScale = 1
        } else if row == 2 {
            position = CGPoint(x: 1099, y: 325)
            velocity = CGVector(dx: -300, dy: 0)
            zPosition = -6
            xScale = -1
        } else {
            position = CGPoint(x: -75, y: 450)
            velocity = CGVector(dx: 300, dy: 0)
            zPosition = -8
            xScale = 1
        }
        
        guard let duck = possibleDucks.randomElement() else { return }
        
        if duck == "duck_outline_target_brown" {
            name = "duck_brown"
        } else if duck == "duck_outline_target_white" {
            name = "duck_white"
        } else {
            name = "duck_yellow"
        }
        
        let sprite = SKSpriteNode(imageNamed: duck)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.position = position
        sprite.zPosition = zPosition
        sprite.xScale = xScale
        sprite.name = name
        sprite.physicsBody?.velocity = velocity
        
        timer-=1
        
        addChild(sprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        let node = touchedNodes.first(where: { $0.name == "duck_white" || $0.name == "duck_brown" || $0.name == "duck_yellow" })
        
        if node?.name == "duck_yellow" {
            score -= 5
            node?.removeFromParent()
        } else if node?.name == "duck_brown" || node?.name == "duck_white" {
            score += 2
            node?.removeFromParent()
        }
        
        let crosshair = SKSpriteNode(imageNamed: "crosshair_white_large")
        crosshair.position = location
        addChild(crosshair)
        
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        crosshair.run(SKAction.sequence([fade, remove]))
        
        run(SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false))
    }
}


