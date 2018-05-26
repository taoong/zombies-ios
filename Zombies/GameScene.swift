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
        zombie = self.childNode(withName: "zombie") as! SKSpriteNode
        button = self.childNode(withName: "button") as! SKSpriteNode
        lastTouch = player.position
        updateCamera()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if button.contains((touches.first?.location(in: self))!) {
            sword.run(SKAction.rotate(byAngle: CGFloat.pi, duration: 0.5))
        } else {
            handleTouch(touches)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
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
    }
    
    override func update(_ currentTime: TimeInterval) {
        
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
