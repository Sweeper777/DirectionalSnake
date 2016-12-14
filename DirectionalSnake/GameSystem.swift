import SpriteKit

class GameSystem {
    var board: [[BoardState]]
    let boardNode: SKSpriteNode
    let snakeSize: CGFloat
    
    init(boardSize: CGFloat) {
        snakeSize = floor(boardSize / 20)
        board = [[BoardState]](repeating: [BoardState](repeating: .empty, count: 20), count: 20)
        boardNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: snakeSize * 20, height: snakeSize * 20))
        boardNode.zPosition = 999
        boardNode.position = CGPoint(x: snakeSize * -10, y: snakeSize * -10)
        boardNode.anchorPoint = CGPoint.zero
    }
}
