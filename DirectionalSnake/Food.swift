import SpriteKit

class Food {
    var x: Int
    var y: Int
    
    let node: SKSpriteNode
    
    init(x: Int, y: Int, nodeSize: CGFloat, orientation: Orientation) {
        self.x = x
        self.y = y
        self.node = SKSpriteNode(imageNamed: "food")
        node.position = CGPoint(x: CGFloat(self.x) * nodeSize + nodeSize / 2, y: CGFloat(self.y) * nodeSize + nodeSize / 2)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.size = CGSize(width: nodeSize, height: nodeSize)
        node.zPosition = 1000
        
        if orientation == .vertical {
            node.zRotation = CGFloat(M_PI / 2)
        }
    }
}
