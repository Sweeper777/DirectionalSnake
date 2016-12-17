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
        guard case .snake(let orientation, let direction) = board[x][y] else { fatalError("Trying to create snake at (\(x), \(y)) where there shouldn't be a snake.") }
        
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
            
            let returnValue = board[finalX][finalY]
            
            if case .snake(_, _) = board[finalX][finalY] {} else {
                if dx == 0 {
                    board[finalX][finalY] = .snake(.vertical, direction)
                } else if dy == 0 {
                    board[finalX][finalY] = .snake(.horizontal, direction)
                } else {
                    fatalError()
                }
            }
            
            x = finalX
            y = finalY
            let nodeSize = node.frame.width
            node.position = CGPoint(x: CGFloat(self.x) * nodeSize + nodeSize / 2, y: CGFloat(self.y) * nodeSize + nodeSize / 2)
            guard case .snake(let newOrientation, _) = board[x][y] else {
                if dx == 0 {
                    updateOrientation(to: .vertical)
                } else if dy == 0 {
                    updateOrientation(to: .horizontal)
                } else {
                    fatalError()
                }
                return returnValue
            }
            updateOrientation(to: newOrientation)
            
            return returnValue
        }
        
        switch direction {
        case .east:
            return move(dx: 1, dy: 0)
        case .north:
            return move(dx: 0, dy: 1)
        case .south:
            return move(dx: 0, dy: -1)
        case .west:
            return move(dx: -1, dy: 0)
        }
    }
}
