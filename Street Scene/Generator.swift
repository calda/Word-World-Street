//
//  Generator.swift
//  Street Scene
//
//  Created by Cal on 9/6/15.
//  Copyright © 2015 Cal. All rights reserved.
//

import Foundation
import SpriteKit

protocol Generator {
    
    var nodes: [SKSpriteNode] { get set }
    var owningScene: SKScene { get set }
    var screenWidth: CGFloat { get }
    var screenHeight: CGFloat { get }
    var yForNewNode: CGFloat { get }
    var zPosition: Int { get }
    
    //to be customized on each generator
    var minimumSpacing: CGFloat { get }
    var maximumSpacing: CGFloat { get }
    
    var edgeBufferWidth: CGFloat { get }
    
    mutating func nodesUpdated()
    mutating func generateNewNode(atFront atFront: Bool)
    func getNewNode() -> (node: SKSpriteNode, aspectRatio: CGFloat)
    mutating func removeNode(node: SKSpriteNode)
    
    func borderOfGroup() -> (left: (position: CGFloat, node: SKSpriteNode?), right: (position: CGFloat, node: SKSpriteNode?))
    
}

extension Generator {
    
    var edgeBufferWidth: CGFloat {
        return 500.0
    }
    
    var screenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.width * UIScreen.mainScreen().scale
    }
    
    var screenHeight: CGFloat {
        return UIScreen.mainScreen().bounds.height * UIScreen.mainScreen().scale
    }
    
    func borderOfGroup() -> (left: (position: CGFloat, node: SKSpriteNode?), right: (position: CGFloat, node: SKSpriteNode?)) {
        var left: (position: CGFloat, node: SKSpriteNode?) = (0, nil)
        var right: (position: CGFloat, node: SKSpriteNode?) = (0, nil)
        
        for node in nodes {
            let leftBorder = node.currentPosition().x
            let rightBorder = node.currentPosition().x + node.size.width
            
            if leftBorder < left.position {
                left = (leftBorder, node)
            }
            
            if rightBorder > right.position {
                right = (rightBorder, node)
            }
        }
        
        return (left, right)
    }
    
    mutating func nodesUpdated() {
        let (left, right) = self.borderOfGroup()
        
        //check for adding new nodes
        if left.position > -100 { generateNewNode(atFront: false) }
        if right.position < screenWidth + 100 { generateNewNode(atFront: true) }
        
        //check for deleting old nodes
        if let leftNode = left.node where left.position < -edgeBufferWidth { removeNode(leftNode) }
        if let rightNode = right.node where right.position > screenWidth + edgeBufferWidth { removeNode(rightNode) }
    }
    
    mutating func generateNewNode(atFront atFront: Bool) {
        let (node, aspectRatio) = getNewNode()
        let size = CGSizeMake(screenHeight * aspectRatio, screenHeight)
        let (left, right) = borderOfGroup()
        let position: CGFloat
        
        if atFront {
            position = (right.position) + getSpacingForNode()
        }
        else {
            position = (left.position - size.width) - getSpacingForNode()
        }
        
        addNode(node, position: CGPointMake(position, yForNewNode), size: size)
    }
    
    func getSpacingForNode() -> CGFloat {
        let min = minimumSpacing
        let max = maximumSpacing
        if min == max { return max }
        
        let random = randomBetween(Int(min), Int(max))
        return CGFloat(random)
    }
    
    mutating func addNode(node: SKSpriteNode, position: CGPoint, size: CGSize) {
        node.zPosition = CGFloat(self.zPosition)
        node.resize(size)
        node.moveTo(position)
        nodes.append(node)
        owningScene.addChild(node)
    }
    
    mutating func removeNode(node: SKSpriteNode) {
        for index in 0 ..< nodes.count {
            if nodes[index].name == node.name {
                //print("Removing \(node.name!) at \(index) (count is currently \(nodes.count))")
                nodes.removeAtIndex(index)
                //print("(count is currently \(nodes.count))")
                break
            }
        }
        node.removeFromParent()
    }
    
}