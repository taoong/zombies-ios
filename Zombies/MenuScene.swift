//
//  MenuScene.swift
//  Zombies
//
//  Created by Tao Ong on 5/27/18.
//  Copyright © 2018 Tao Ong. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var score: Int!
    
    override func didMove(to view: SKView) {
        let scoreLabel = SKLabelNode(text: "Final score: " + String(score))
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY / 2)
        scoreLabel.fontSize = 50
        self.addChild(scoreLabel)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameScene)
    }
}
