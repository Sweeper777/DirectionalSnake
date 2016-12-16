import SpriteKit

class SnakeBody {
    var x: Int
    var y: Int
    
    let node: SKSpriteNode
    
    init(x: Int, y: Int, nodeSize: CGFloat, orientation: Orientation) {
        self.x = x
        self.y = y
        self.node = SKSpriteNode(imageNamed: "straightSnake")
        node.position = CGPoint(x: CGFloat(self.x) * nodeSize + nodeSize / 2, y: CGFloat(self.y) * nodeSize + nodeSize / 2)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.size = CGSize(width: nodeSize, height: nodeSize)
        node.zPosition = 1000
        updateOrientation(to: orientation)
    }
    
    func updateOrientation(to orientation: Orientation) {
        switch orientation {
        case .horizontal, .vertical:
            node.texture = SKTexture(imageNamed: "straightSnake")
        default:
            node.texture = SKTexture(imageNamed: "angleSnake")
        }
        
        node.zRotation = 0
        switch orientation {
        case .vertical, .southWest:
            node.zRotation = CGFloat(M_PI / 2)
        case .southEast:
            node.zRotation = CGFloat(M_PI)
        case .northEast:
            node.zRotation = CGFloat(M_PI / 2 * 3)
        default:
            break
        }
    }
    
    func move(in board: inout [[BoardState]]) -> BoardState {
        
        func move(dx: Int, dy: Int) -> BoardState {
            let finalX: Int
            switch x + dx {
            case -1:
                finalX = board.count - 1
            case board.count:
                finalX = 0
            default:
                finalX = x + dx
            }
            
            let finalY: Int
            switch y + dy {
            case -1:
                finalY = board[x].count - 1
            case board[x].count:
                finalY = 0
            default:
                finalY = y + dy
            }
            
        }
    }
}
