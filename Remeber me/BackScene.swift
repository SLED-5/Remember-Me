//
//  BackScene.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/1/23.
//

import SpriteKit

class BackScene: SKScene {
    
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()
    private var bgSpeed: CGFloat = 8
    private var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    
    override func didMove(to view: SKView) {
        createBackground()
    }
    
    override func update(_ currentTime: TimeInterval) {
        background1.position.x -= 0.002
        background2.position.x -= 0.002
        
        if(background1.position.x < -background1.size.width)
        {
            background1.position = CGPointMake(background2.position.x + background2.size.width, background1.position.y )
        }

        if(background2.position.x < -background2.size.width)
        {
            background2.position = CGPointMake(background1.position.x + background1.size.width, background2.position.y)

        }

                    
    }
    
    func createBackground() {
        background1 = SKSpriteNode(imageNamed: "background")
        background2 = SKSpriteNode(imageNamed: "background")
        
        background1.anchorPoint = CGPoint(x: 0, y: 0)
        background1.size = CGSize(width: frame.width * 2, height: frame.height)
        background1.position = CGPoint(x:0, y: 0)
        background1.zPosition = 1
        background1.name = "background1"
        self.addChild(background1)
        
        background2.anchorPoint = CGPoint(x:0, y: 0)
        background2.size = CGSize(width: frame.width * 2, height: frame.height)
        background2.position = CGPoint(x:background1.size.width, y: 0)
        background2.zPosition = 2
        background2.name = "background2"
        self.addChild(background2)
        
    }
    
}
private func + (left: CGPoint, right: CGPoint) -> CGPoint {
   return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

private func += (left: inout CGPoint, right: CGPoint) {
   left = left + right
}
