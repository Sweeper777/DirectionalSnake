import SpriteKit

class SnakeBody {
    var x: Int
    var y: Int
    
    let node: SKSpriteNode
    
    init(x: Int, y: Int, nodeSize: CGFloat, orientation: Orientation) {
        self.x = x
        self.y = y
        self.node = SKSpriteNode(imageNamed: "straightSnake")
        node.position = CGPoint(x: CGFloat(self.x) * nodeSize, y: CGFloat(self.y) * nodeSize)
        node.anchorPoint = CGPoint.zero
        node.size = CGSize(width: nodeSize, height: nodeSize)
        node.zPosition = 1000
    }
}
