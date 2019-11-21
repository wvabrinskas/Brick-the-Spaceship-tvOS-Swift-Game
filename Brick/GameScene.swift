//
//  GameScene.swift
//  Brick
//
//  Created by william vabrinskas on 12/18/15.
//  Copyright (c) 2015 William Vabrinskas. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var character = SKSpriteNode()
    var ground = SKNode()
    var wallCat: UInt32 = 0x1 << 2
    var playerCat: UInt32 = 0x1 << 1
    var worldNode = SKNode();
    var enemyController = WVEnemyController()
    var playAgain = SKLabelNode()
    var died = Bool()
    var score = SKLabelNode()
    var topBlock = SKNode()
    var emissionSprite = SKEmitterNode()
    var explosionSprite = SKEmitterNode()
    var stars = SKEmitterNode()
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        died = false
        self.physicsBody = SKPhysicsBody.init(edgeLoopFrom:CGRect(x: self.frame.origin.x,y: self.frame.origin.y + 100,width: self.frame.width,height: self.frame.height - 100))
        self.physicsWorld.gravity = CGVector.zero
        self.physicsBody?.categoryBitMask = wallCat
        self.physicsWorld.contactDelegate = self
        self.setupWalls()
        self.setupCharacter()
        self.generateEmitter()
        self.generateStars()
        enemyController = WVEnemyController.init()
        enemyController.setupEnemiesInNode(node: worldNode,frame: self.frame)
        enemyController.startTimerForEnemies()
        
    }
    
    func xImpulse()->CGFloat {
        return 200.0
    }
    
    
    func setupWalls () {
        worldNode = SKNode.init()
        worldNode.position = self.frame.origin
        worldNode.zPosition = 1;
        
        topBlock = SKNode.init()
        topBlock.physicsBody = SKPhysicsBody.init(edgeLoopFrom:CGRect(x: self.frame.origin.x, y: self.frame.maxY - 300, width: self.frame.width, height: 10))
        topBlock.physicsBody?.categoryBitMask = wallCat
        topBlock.zPosition = 2
        worldNode.addChild(topBlock)
        self.addChild(worldNode)
    }
    
    func setupCharacter (){
        character = SKSpriteNode(imageNamed: "player")
        character.xScale = 0.5;
        character.yScale = 0.5
        character.zPosition = 2;
        character.position = CGPoint(x: self.frame.midX, y: 200)
        character.physicsBody=SKPhysicsBody.init(rectangleOf:character.size);
        character.physicsBody?.isDynamic = true
        character.physicsBody?.contactTestBitMask = wallCat
        character.physicsBody?.collisionBitMask = 0xffffffff;
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.categoryBitMask = playerCat
        character.physicsBody?.density = 1.5
        character.physicsBody?.allowsRotation = false;
        worldNode.addChild(character)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let prevLocation:CGPoint = touch.previousLocation(in: worldNode)
            let location = touch.location(in: worldNode)
            
            
            // emissionSprite.runAction(totalActions)
            
            if location.x > prevLocation.x {
                //finger touch went right
                character.physicsBody?.applyForce(CGVector(dx:self.xImpulse(), dy:0))
            }
            
            if location.x < prevLocation.x {
                //went left
                character.physicsBody?.applyForce(CGVector(dx:-self.xImpulse(), dy:0))
                
            }
            
            if location.y > prevLocation.y {
                character.physicsBody?.applyForce(CGVector(dx: 0, dy: self.xImpulse()))
            }
            
            
            if location.y < prevLocation.y {
                character.physicsBody?.applyForce(CGVector(dx: 0, dy: -self.xImpulse()))
            }
        }
        
    }
    
    func generateExplosion() {
        explosionSprite = SKEmitterNode(fileNamed: "explosion.sks")!
        explosionSprite.position = character.position
        explosionSprite.zPosition = 3
        worldNode.addChild(explosionSprite)
        let delay = SKAction.wait(forDuration: 0.4)
        explosionSprite.run(delay) { () -> Void in
            // self.character.removeFromParent()
        }
    }
    
    func generateEmitter () {
        
        emissionSprite = SKEmitterNode(fileNamed: "trailEmitter.sks")!
        emissionSprite.position = character.position
        emissionSprite.zPosition = 2
        worldNode.addChild(emissionSprite)
        
    }
    
    func generateStars () {
        
        stars = SKEmitterNode(fileNamed: "stars.sks")!
        stars.position = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        stars.particlePositionRange = CGVector(dx:self.frame.size.width,dy: 5)
        stars.zPosition = 2
        stars.speed = 1.0
        worldNode.addChild(stars)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if died {
            self.removeAllChildren()
            self.didMove(to: self.view!)
            worldNode.speed = 1
            playAgain.removeFromParent()
        }
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let moveY:SKAction = SKAction.moveTo(y: character.position.y - (character.size.height - 20), duration: 0)
        let moveX:SKAction = SKAction.moveTo(x: character.position.x, duration: 0)
        let totalActions:SKAction = SKAction.sequence([moveX,moveY])
        emissionSprite.run(totalActions)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == playerCat && contact.bodyB.categoryBitMask == 0x1 << 0) || (contact.bodyA.categoryBitMask == 0x1 << 0 && contact.bodyB.categoryBitMask == playerCat) {
            died = true
            worldNode.speed = 0
            stars.isPaused = true
            character.removeAllActions()
            generateExplosion()
            self.character.removeFromParent()
            emissionSprite.removeFromParent()
            self.removeAction(forKey: "enemy")
            playAgain = SKLabelNode.init(text: "Tap to play again")
            playAgain.fontSize = 30
            playAgain.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
            playAgain.zPosition = 4
            worldNode.addChild(playAgain)
            
        }
        
    }
}
