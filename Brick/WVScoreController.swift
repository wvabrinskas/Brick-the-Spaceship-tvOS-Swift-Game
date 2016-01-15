//
//  WVScoreController.swift
//  Brick
//
//  Created by william vabrinskas on 12/22/15.
//  Copyright © 2015 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class WVScoreController {
    
    var sceneFrame: CGRect = CGRect()
    var parentNode = SKNode()
    var scoreLabel = SKLabelNode()
    var score = SKLabelNode()
    var scoreValue:Int = Int()
    
    func setupScoringWithNode(node: SKNode, frame: CGRect) {
        
        parentNode = node
        sceneFrame = frame
        self.layoutLabels()
    }
    
    func layoutLabels() {
        
        score = SKLabelNode.init(text: "\(0)")
        score.fontSize = 20
        score.fontColor = UIColor.whiteColor()
        score.position = CGPointMake(CGRectGetMidX(sceneFrame),CGRectGetMaxY(sceneFrame) - 150)
        parentNode.addChild(score)
        score.zPosition = 4
        scoreLabel = SKLabelNode.init(text: "Score:")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.position = CGPointMake(CGRectGetMidX(sceneFrame) - 50,CGRectGetMaxY(sceneFrame) - 150)
        scoreLabel.zPosition = 4
        parentNode.addChild(scoreLabel)
    }
    
    func resetScore () {
        scoreValue = 0
    }
    
    func updateScore () {
        scoreValue++
        score.text = "\(scoreValue)"
    }
    
     func getScore()->Int {
        return scoreValue
    }
    
    
}