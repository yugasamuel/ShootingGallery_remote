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
    var rifle: SKSpriteNode!
    var crosshair: SKSpriteNode!
    
    var gameTimer: Timer?

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let possibleDucks = ["duck_outline_brown", "duck_outline_white", "duck_outline_yellow"]
    
    override func didMove(to view: SKView) {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createDuck), userInfo: nil, repeats: true)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 512, y: 530)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = 52
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        rifle = SKSpriteNode(imageNamed: "rifle")
        rifle.position = CGPoint(x: 840, y: 100)
        addChild(rifle)
        
        score = 0
        
        removeBackgroundInteractions()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func removeBackgroundInteractions() {
        let sprite = childNode(withName: "SKSpriteNode")
        sprite?.isUserInteractionEnabled = false
    }
    
    @objc func createDuck() {
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
        
        if duck == "duck_outline_brown" {
            name = "duck_brown"
        } else if duck == "duck_outline_white" {
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

        addChild(sprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "duck_yellow" {
            score += 2
            touchedNode.removeFromParent()
        } else if touchedNode.name == "duck_brown" || touchedNode.name == "duck_white" {
            score += 1
            touchedNode.removeFromParent()
        }
        
        run(SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false))
    }
}


