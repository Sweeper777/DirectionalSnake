import SpriteKit
import SwiftRandom
import EZSwiftExtensions

class GameSystem {
    var board: [[BoardState]]
    let boardNode: SKSpriteNode
    let snakeSize: CGFloat
    var snake: [SnakeBody] = []
    var currentFood: Food?
    var canChangeDirection = true
    weak var delegate: GameSystemDelegate?
    
    init(boardSize: CGFloat) {
        snakeSize = floor(boardSize / 20)
        board = [[BoardState]](repeating: [BoardState](repeating: .empty, count: 20), count: 20)
        boardNode = SKSpriteNode(color: UIColor(hexString: "8dee8d")!, size: CGSize(width: snakeSize * 20, height: snakeSize * 20))
        boardNode.zPosition = 999
        boardNode.position = CGPoint(x: snakeSize * -10, y: snakeSize * -10)
        boardNode.anchorPoint = CGPoint.zero
        
        snake.append(SnakeBody(x: 0, y: 0, nodeSize: snakeSize, orientation: .northEast))
        boardNode.addChild(snake[0].node)
        
        board[0][0] = .snake(.northEast, .east)
        
        let runCodeAction = SKAction.run { [unowned self] in self.moveWholeSnake() }
        boardNode.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.5), runCodeAction])))
        
        generateFood()
    }
    
    func generateFood() {
        var coordinates = [(Int, Int)]()
        for x in 0..<board.count {
            for y in 0..<board[x].count {
                if case .empty = board[x][y] {
                    coordinates.append((x, y))
                }
            }
        }
        if let coordinate = coordinates.randomItem() {
            let foodOrientation: Orientation = Bool.random() ? .vertical : .horizontal
            currentFood = Food(x: coordinate.0, y: coordinate.1, nodeSize: snakeSize, orientation: foodOrientation)
            boardNode.addChild(currentFood!.node)
            board[coordinate.0][coordinate.1] = .food(foodOrientation)
        }
    }
    
    func moveWholeSnake() {
        let lastX = self.snake.last!.x
        let lastY = self.snake.last!.y
        let moveResult = self.snake.first!.move(in: &self.board)
        for snakeBody in self.snake.dropFirst().dropLast() {
            _ = snakeBody.move(in: &self.board)
        }
        if self.snake.count > 1 {
            _ = self.snake.last!.move(in: &self.board)
        }
        self.board[lastX][lastY] = .empty
        if case .food(let orientation) = moveResult {
            let snakeOrientation: Orientation
            switch getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!.1 {
            case .north, .south:
                snakeOrientation = .vertical
            case .east, .west:
                snakeOrientation = .horizontal
            }
            if snakeOrientation != orientation {
                gameOver()
                return
            }
            
            currentFood!.node.removeFromParent()
            increaseSnakeLength()
            generateFood()
        } else if case .snake = moveResult {
            gameOver()
            return
        }
        canChangeDirection = true
    }
    
    func increaseSnakeLength() {
        var dx = 0
        var dy = 0
        let x = snake.first!.x
        let y = snake.first!.y
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        switch tuple.1 {
        case .east:
            dx = 1
        case .north:
            dy = 1
        case .south:
            dy = -1
        case .west:
            dx = -1
        }
        
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
        
        if case .snake = board[finalX][finalY] {
            gameOver()
            return
        }
        
        if dx == 0 {
            board[finalX][finalY] = .snake(.vertical, tuple.1)
            snake.insert(SnakeBody(x: finalX, y: finalY, nodeSize: snakeSize, orientation: .vertical), at: 0)
            boardNode.addChild(snake.first!.node)
        } else if dy == 0 {
            board[finalX][finalY] = .snake(.horizontal, tuple.1)
            snake.insert(SnakeBody(x: finalX, y: finalY, nodeSize: snakeSize, orientation: .horizontal), at: 0)
            boardNode.addChild(snake.first!.node)
        }
    }
    
    func getOrientationAndDirectionOfSnakeBody(snakeBody: SnakeBody) -> (Orientation, Direction)? {
        guard case .snake(let orientation, let direction) = board[snakeBody.x][snakeBody.y] else { return nil }
        return (orientation, direction)
    }
    
    @objc func swipedUp() {
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .south && tuple.1 != .north else { return }
        if tuple.1 == .east {
            board[snake.first!.x][snake.first!.y] = .snake(.northWest, .north)
        } else if tuple.1 == .west {
            board[snake.first!.x][snake.first!.y] = .snake(.northEast, .north)
        }
    }
    
    @objc func swipedDown() {
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .south && tuple.1 != .north else { return }
        if tuple.1 == .east {
            board[snake.first!.x][snake.first!.y] = .snake(.southWest, .south)
        } else if tuple.1 == .west {
            board[snake.first!.x][snake.first!.y] = .snake(.southEast, .south)
        }
    }
    
    @objc func swipedLeft() {
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .east && tuple.1 != .west else { return }
        if tuple.1 == .north {
            board[snake.first!.x][snake.first!.y] = .snake(.southWest, .west)
        } else if tuple.1 == .south {
            board[snake.first!.x][snake.first!.y] = .snake(.northWest, .west)
        }
    }
    
    @objc func swipedRight() {
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .east && tuple.1 != .west else { return }
        if tuple.1 == .north {
            board[snake.first!.x][snake.first!.y] = .snake(.southEast, .east)
        } else if tuple.1 == .south {
            board[snake.first!.x][snake.first!.y] = .snake(.northEast, .east)
        }
    }
    
    func gameOver() {
        boardNode.removeAllActions()
        
        for child in boardNode.children.dropLast() {
            child.run(SKAction.fadeOut(withDuration: 1))
        }
        boardNode.children.last!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.run { [unowned self] in self.delegate?.didGameOver(gameSystem: self) }]))
    }
}
