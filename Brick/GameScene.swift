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

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        died = false
        self.physicsBody = SKPhysicsBody.init(edgeLoopFromRect:CGRectMake(self.frame.origin.x,self.frame.origin.y + 100,self.frame.width,self.frame.height - 100))
        self.physicsWorld.gravity=CGVectorMake(0,0);
        self.physicsBody?.categoryBitMask = wallCat
        self.physicsWorld.contactDelegate = self
        self.setupWalls()
        self.setupCharacter()
        self.generateEmitter()
        self.generateStars()
        enemyController = WVEnemyController.init()
        enemyController.setupEnemiesInNode(worldNode,frame: self.frame)
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
        topBlock.physicsBody = SKPhysicsBody.init(edgeLoopFromRect:CGRectMake(self.frame.origin.x,CGRectGetMaxY(self.frame) - 300,self.frame.width,10))
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
        character.position = CGPointMake(CGRectGetMidX(self.frame),200);
        character.physicsBody=SKPhysicsBody.init(rectangleOfSize:character.size);
        character.physicsBody?.dynamic = true
        character.physicsBody?.contactTestBitMask = wallCat
        character.physicsBody?.collisionBitMask = 0xffffffff;
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.categoryBitMask = playerCat
        character.physicsBody?.density = 1.5
        character.physicsBody?.allowsRotation = false;
        worldNode.addChild(character)
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let prevLocation:CGPoint = touch.previousLocationInNode(worldNode)
            let location = touch.locationInNode(worldNode)

  
         
           // emissionSprite.runAction(totalActions)
            
            if location.x > prevLocation.x {
                //finger touch went right
                character.physicsBody?.applyForce(CGVectorMake(self.xImpulse(), 0))
            }
            
            if location.x < prevLocation.x {
                //went left
                character.physicsBody?.applyForce(CGVectorMake(-self.xImpulse(), 0))

            }
            
            if location.y > prevLocation.y {
                 character.physicsBody?.applyForce(CGVectorMake(0,self.xImpulse()))
            }
            
            
            if location.y < prevLocation.y {
                character.physicsBody?.applyForce(CGVectorMake(0, -self.xImpulse()))
            }
            
            
            
        }
        
        
    }

    
    func generateExplosion() {
        explosionSprite = SKEmitterNode(fileNamed: "explosion.sks")!
        explosionSprite.position = character.position
        explosionSprite.zPosition = 3
        worldNode.addChild(explosionSprite)
        let delay = SKAction.waitForDuration(0.4)
        explosionSprite.runAction(delay) { () -> Void in
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
        stars.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame))
        stars.particlePositionRange = CGVectorMake(self.frame.size.width,5)
        stars.zPosition = 2
        stars.speed = 1.0
        worldNode.addChild(stars)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if died {
            self.removeAllChildren()
            self.didMoveToView(self.view!)
            worldNode.speed = 1
            playAgain.removeFromParent()
        }
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let moveY:SKAction = SKAction.moveToY(character.position.y - (character.size.height - 20), duration: 0)
        let moveX:SKAction = SKAction.moveToX(character.position.x, duration: 0)
        let totalActions:SKAction = SKAction.sequence([moveX,moveY])
        emissionSprite.runAction(totalActions)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == playerCat && contact.bodyB.categoryBitMask == 0x1 << 0) || (contact.bodyA.categoryBitMask == 0x1 << 0 && contact.bodyB.categoryBitMask == playerCat) {
                died = true
                worldNode.speed = 0
                stars.paused = true
                character.removeAllActions()
                generateExplosion()
             self.character.removeFromParent()
                emissionSprite.removeFromParent()
                self.removeActionForKey("enemy")
                playAgain = SKLabelNode.init(text: "Tap to play again")
                playAgain.fontSize = 30
                playAgain.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
                playAgain.zPosition = 4
                worldNode.addChild(playAgain)
            
        }

    }
}
