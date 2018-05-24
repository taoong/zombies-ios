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
    var playerSpeed : CGFloat = 150
    var lastTouch : CGPoint?
    
    override func sceneDidLoad() {
        player = self.childNode(withName: "player") as! SKSpriteNode
        zombie = self.childNode(withName: "zombie") as! SKSpriteNode
        lastTouch = player.position
        updateCamera()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
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
