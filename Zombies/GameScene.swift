//
//  GameScene.swift
//  Zombies
//
//  Created by Tao Ong on 5/19/18.
//  Copyright © 2018 Tao Ong. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var sword = SKSpriteNode()
    var swordAnchor = SKSpriteNode(color: UIColor.white, size: CGSize(width: 1, height: 1))
    var zombies : [SKSpriteNode] = []
    var button = SKSpriteNode()
    var playerSpeed : CGFloat = 150
    var zombieSpeed : CGFloat = 100
    var lastTouch : CGPoint?
    var score : Int = 0
    var scoreLabel = SKLabelNode()
    
    override func sceneDidLoad() {
        player = self.childNode(withName: "player") as! SKSpriteNode
        button = self.childNode(withName: "button") as! SKSpriteNode
        sword = self.childNode(withName: "sword") as! SKSpriteNode
        scoreLabel = self.childNode(withName: "score") as! SKLabelNode
        swordAnchor.physicsBody = SKPhysicsBody(rectangleOf: swordAnchor.frame.size)
        swordAnchor.physicsBody!.affectedByGravity = false
        swordAnchor.physicsBody!.mass = 9999999999
        swordAnchor.position = player.position
        self.addChild(swordAnchor)
        let joint = SKPhysicsJointPin.joint(
            withBodyA:  swordAnchor.physicsBody!,
            bodyB: sword.physicsBody!,
            anchor: swordAnchor.position)
        self.physicsWorld.add(joint)
        self.physicsWorld.contactDelegate = self
        lastTouch = player.position
        for _ in 1...5 {
            zombies.append(createZombie())
        }
        for z in zombies {
            self.addChild(z)
        }
        updateCamera()
    }
    
    func createZombie() -> SKSpriteNode {
        let newZombie = SKSpriteNode(color: UIColor.green, size: CGSize(width: 40, height: 40))
        newZombie.physicsBody = SKPhysicsBody(rectangleOf: newZombie.frame.size)
        newZombie.physicsBody!.affectedByGravity = false
        newZombie.physicsBody?.categoryBitMask = 4
        newZombie.physicsBody?.contactTestBitMask = 3
        newZombie.physicsBody?.collisionBitMask = 0
        
        // Generate random position far from player
        var new_x = player.position.x + CGFloat(arc4random_uniform(1000)) - 500
        var new_y = player.position.y + CGFloat(arc4random_uniform(1000)) - 500
        while abs(new_x - player.position.x) < 200 {
            new_x = player.position.x + CGFloat(arc4random_uniform(1000)) - 500
        }
        while abs(new_x - player.position.x) < 200 {
            new_y = player.position.y + CGFloat(arc4random_uniform(1000)) - 500
        }
        
        newZombie.position = CGPoint(x: new_x, y: new_y)
        return newZombie
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if button.contains((touches.first?.location(in: self))!) {
            sword.run(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5))
        } else {
            handleTouch(touches)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !button.contains((touches.first?.location(in: self))!) {
            handleTouch(touches)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !button.contains((touches.first?.location(in: self))!) {
            handleTouch(touches)
        }
    }
    
    func handleTouch(_ touches: Set<UITouch>) {
        lastTouch = touches.first?.location(in: self)
    }
    
    func shouldMove(_ touchPosition: CGPoint, _ currentPosition: CGPoint) -> Bool {
        return abs(currentPosition.x - touchPosition.x) > player.frame.width / 2 ||
            abs(currentPosition.y - touchPosition.y) > player.frame.height / 2
    }
    
    func updateCamera() {
        camera?.position = player.position
        button.position = CGPoint(x: player.position.x - 137, y: player.position.y - 283)
        scoreLabel.position = CGPoint(x: player.position.x, y: player.position.y + 80)
    }
    
    func updatePlayerPosition(for sprite: SKSpriteNode,
                        to target: CGPoint) {
        let currentPosition = player.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                       currentPosition.x - target.x)
        let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5),
                                           duration: 0)
        
        player.run(rotateAction)
        
        let velocityX = playerSpeed * cos(angle)
        let velocityY = playerSpeed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        player.physicsBody?.velocity = newVelocity
        
        swordAnchor.position = player.position
        if !sword.hasActions() {
            sword.position = CGPoint(x: player.position.x + 40, y: player.position.y)
        }
    }
    
    func updateZombiePosition(for sprites: [SKSpriteNode], to target: CGPoint) {
        for zombie in zombies {
            let currentPosition = zombie.position
            let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                           currentPosition.x - target.x)
            let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5),
                                               duration: 0)
            
            zombie.run(rotateAction)
            
            let velocityX = zombieSpeed * cos(angle)
            let velocityY = zombieSpeed * sin(angle)
            
            let newVelocity = CGVector(dx: velocityX, dy: velocityY)
            zombie.physicsBody?.velocity = newVelocity
        }
    }
    
    func updateScore() {
        score += 1
        scoreLabel.text = String(score)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the
        // lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == 2 && secondBody.categoryBitMask == 4 {
            // REMOVE ZOMBIE
            self.removeChildren(in: [secondBody.node!])
            updateScore()
            
            // ADD NEW ONE
            let newZombie = createZombie()
            zombies.append(newZombie)
            self.addChild(newZombie)
            updateZombiePosition(for: zombies, to: player.position)
        }
        
        if firstBody.categoryBitMask == 1 && secondBody.categoryBitMask == 4 {
            print("zombie killed you!")
            player.color = UIColor.clear
            let menuScene = MenuScene(fileNamed: "MenuScene")
            menuScene?.scaleMode = .aspectFill
            self.view?.presentScene(menuScene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        swordAnchor.position = player.position
    }
    
    override func didSimulatePhysics() {
        if shouldMove(lastTouch!, player.position) {
            updatePlayerPosition(for: player, to: lastTouch!)
            updateZombiePosition(for: zombies, to: player.position)
            updateCamera()
        } else {
            player.physicsBody?.isResting = true
        }
    }
}
