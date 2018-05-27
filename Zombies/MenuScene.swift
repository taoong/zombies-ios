//
//  MenuScene.swift
//  Zombies
//
//  Created by Tao Ong on 5/27/18.
//  Copyright © 2018 Tao Ong. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameScene)
    }
}
