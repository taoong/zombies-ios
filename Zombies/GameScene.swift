//
//  GameScene.swift
//  Zombies
//
//  Created by Tao Ong on 5/19/18.
//  Copyright © 2018 Tao Ong. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player = SKSpriteNode()
    var sword = SKSpriteNode()
    var swordAnchor = SKSpriteNode(color: UIColor.white, size: CGSize(width: 1, height: 1))
    var zombie = SKSpriteNode()
    var button = SKSpriteNode()
    var playerSpeed : CGFloat = 150
    var lastTouch : CGPoint?
    
    override func sceneDidLoad() {
        player = self.childNode(withName: "player") as! SKSpriteNode
        zombie = self.childNode(withName: "zombie") as! SKSpriteNode
        button = self.childNode(withName: "button") as! SKSpriteNode
        sword = self.childNode(withName: "sword") as! SKSpriteNode
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
        lastTouch = player.position
        updateCamera()
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
    }
    
    func updatePosition(for sprite: SKSpriteNode,
                        to target: CGPoint) {
        let currentPosition = player.position
        let angle = CGFloat.pi + atan2(currentPosition.y - (lastTouch?.y)!,
                                       currentPosition.x - (lastTouch?.x)!)
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
    
    override func update(_ currentTime: TimeInterval) {
        swordAnchor.position = player.position
    }
    
    override func didSimulatePhysics() {
        if shouldMove(lastTouch!, player.position) {
            updatePosition(for: player, to: lastTouch!)
            updateCamera()
        } else {
            player.physicsBody?.isResting = true
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
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
            print("killed a zombie!")
            zombie.color = UIColor.cyan
        }
        
        if firstBody.categoryBitMask == 1 && secondBody.categoryBitMask == 4 {
            print("zombie killed you!")
            player.color = UIColor.clear
        }
    }
}
