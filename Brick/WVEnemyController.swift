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
        scoreController.setupScoringWithNode(node, frame: frame)
        self.layoutEnemy()

    }
    
     func layoutEnemy () {
        
        enemy = SKSpriteNode.init(imageNamed: "asteroid1")
        enemy.xScale = 2.0;
        enemy.yScale = 2.0;
        enemy.zPosition = 2;
        enemy.physicsBody = SKPhysicsBody.init(rectangleOfSize:enemy.size);
        enemy.physicsBody?.categoryBitMask = enemyCat
        enemy.physicsBody?.contactTestBitMask = 0x1 << 1
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        
        let lowerBound = UInt32(CGRectGetMinX(sceneFrame));
        let upperBound = UInt32(CGRectGetMaxX(sceneFrame));
        let num = arc4random_uniform(upperBound) + lowerBound
        
        enemy.position = CGPointMake(CGFloat(num),CGRectGetMaxY(sceneFrame) - enemy.size.height)
        
        parentNode.addChild(enemy)
    }
    
    func updateScore () {
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
    
    
    func randomlyGenerateEnemy() {
        self.layoutEnemy()
        let updateScore = SKAction.performSelector(Selector("updateScore"), onTarget:self)
        let node: SKSpriteNode = enemy
        let spin:SKAction = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        let spinForever:SKAction = SKAction.repeatActionForever(spin)
        let move:SKAction = SKAction.moveToY(CGRectGetMinY(sceneFrame) - enemy.size.height, duration:self.spawnInterval())
        let returnToStart:SKAction = SKAction.removeFromParent()
        node.runAction(spinForever)
        node.runAction(move) { () -> Void in
            node.runAction(updateScore, completion: { () -> Void in
                node.runAction(returnToStart)
            })
        }

    }
    
    func startTimerForEnemies () {
    
        let spawn:SKAction = SKAction.performSelector(Selector("randomlyGenerateEnemy"), onTarget:self)
        let delay:SKAction = SKAction.waitForDuration(0.5)
        let spawnThenDelay:SKAction = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever:SKAction = SKAction.repeatActionForever(spawnThenDelay)
        enemy.runAction(spawnThenDelayForever, withKey:"enemy")
 
    }
    
    func stopTimerForEnemies () {
        enemy.removeAllActions()
    }
}