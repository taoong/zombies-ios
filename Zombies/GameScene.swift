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
    var zombie = SKSpriteNode()
    var lastTouch : CGPoint?
    
    override func sceneDidLoad() {
        player = self.childNode(withName: "player") as! SKSpriteNode
        zombie = self.childNode(withName: "zombie") as! SKSpriteNode
        lastTouch = player.position
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = touches.first?.location(in: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let currentPosition = player.position
        let angle = CGFloat.pi + atan2(currentPosition.y - (lastTouch?.y)!,
                                       currentPosition.x - (lastTouch?.x)!)
        let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5),
                                           duration: 0)
        player.run(rotateAction)
        
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        player.physicsBody?.velocity = newVelocity
    }
}
