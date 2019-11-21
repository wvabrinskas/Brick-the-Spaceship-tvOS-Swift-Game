//
//  WVEnemyController.swift
//  Brick
//
//  Created by william vabrinskas on 12/21/15.
//  Copyright © 2015 William Vabrinskas. All rights reserved.
//

import Foundation
import SpriteKit


class WVEnemyController: NSObject {
    
    var enemy = SKSpriteNode()
    var enemyCat: UInt32 = 0x1 << 0
    var sceneFrame: CGRect = CGRect()
    var parentNode = SKNode()
    var scoreController: WVScoreController = WVScoreController()

    func setupEnemiesInNode (node: SKNode, frame: CGRect) {
        sceneFrame = frame;
        parentNode = node
        scoreController = WVScoreController.init()
        scoreController.setupScoringWithNode(node: node, frame: frame)
        self.layoutEnemy()

    }
    
     func layoutEnemy () {
        
        enemy = SKSpriteNode.init(imageNamed: "asteroid1")
        enemy.xScale = 2.0;
        enemy.yScale = 2.0;
        enemy.zPosition = 2;
        enemy.physicsBody = SKPhysicsBody.init(rectangleOf:enemy.size);
        enemy.physicsBody?.categoryBitMask = enemyCat
        enemy.physicsBody?.contactTestBitMask = 0x1 << 1
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        
        let lowerBound = UInt32(sceneFrame.minX);
        let upperBound = UInt32(sceneFrame.maxX);
        let num = arc4random_uniform(upperBound) + lowerBound
        
        enemy.position = CGPoint(x: CGFloat(num),y: sceneFrame.maxY - enemy.size.height)
        
        parentNode.addChild(enemy)
    }
    
    @objc public func updateScore() {
        scoreController.updateScore()
    }
    
    func spawnInterval () -> Double {

        let y = scoreController.getScore()
        let interval = (y - 250) / -50
        let val = 0.1
        if interval <= 0 {
            return val
        }
        return Double(interval)
    }
    
    
    @objc func randomlyGenerateEnemy() {
        self.layoutEnemy()
        let update = SKAction.perform(#selector(updateScore), onTarget:self)
        let node: SKSpriteNode = enemy
        let spin:SKAction = SKAction.rotate(byAngle: CGFloat.pi, duration:1)
        let spinForever:SKAction = SKAction.repeatForever(spin)
        let move:SKAction = SKAction.moveTo(y: sceneFrame.minY - enemy.size.height, duration:self.spawnInterval())
        let returnToStart:SKAction = SKAction.removeFromParent()
        node.run(spinForever)
        node.run(move) { () -> Void in
            node.run(update, completion: { () -> Void in
                node.run(returnToStart)
            })
        }

    }
    
    func startTimerForEnemies () {
    
        let spawn:SKAction = SKAction.perform(#selector(randomlyGenerateEnemy), onTarget:self)
        let delay:SKAction = SKAction.wait(forDuration: 0.5)
        let spawnThenDelay:SKAction = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever:SKAction = SKAction.repeatForever(spawnThenDelay)
        enemy.run(spawnThenDelayForever, withKey:"enemy")
 
    }
    
    func stopTimerForEnemies () {
        enemy.removeAllActions()
    }
}
