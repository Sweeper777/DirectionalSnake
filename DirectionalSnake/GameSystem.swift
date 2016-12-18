import SpriteKit
import SwiftRandom

class GameSystem {
    var board: [[BoardState]]
    let boardNode: SKSpriteNode
    let snakeSize: CGFloat
    var snake: [SnakeBody] = []
    var currentFood: Food?
    
    init(boardSize: CGFloat) {
        snakeSize = floor(boardSize / 20)
        board = [[BoardState]](repeating: [BoardState](repeating: .empty, count: 20), count: 20)
        boardNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: snakeSize * 20, height: snakeSize * 20))
        boardNode.zPosition = 999
        boardNode.position = CGPoint(x: snakeSize * -10, y: snakeSize * -10)
        boardNode.anchorPoint = CGPoint.zero
        
        snake.append(SnakeBody(x: 0, y: 0, nodeSize: snakeSize, orientation: .northEast))
        boardNode.addChild(snake[0].node)
        
        snake.append(SnakeBody(x: 0, y: 1, nodeSize: snakeSize, orientation: .vertical))
        boardNode.addChild(snake[1].node)
        
        board[0][0] = .snake(.northEast, .east)
        board[0][1] = .snake(.vertical, .south)
        
        let runCodeAction = SKAction.run(moveWholeSnake)
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
        let moveResult = self.snake.first!.move(in: &self.board)
        for snakeBody in self.snake.dropFirst().dropLast() {
            _ = snakeBody.move(in: &self.board)
        }
        let lastX = self.snake.last!.x
        let lastY = self.snake.last!.y
        _ = self.snake.last!.move(in: &self.board)
        self.board[lastX][lastY] = .empty
    }
    
    func getOrientationAndDirectionOfSnakeBody(snakeBody: SnakeBody) -> (Orientation, Direction)? {
        guard case .snake(let orientation, let direction) = board[snakeBody.x][snakeBody.y] else { return nil }
        return (orientation, direction)
    }
    
    @objc func swipedUp() {
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .south && tuple.1 != .north else { return }
        if tuple.1 == .east {
            board[snake.first!.x][snake.first!.y] = .snake(.northWest, .north)
        } else if tuple.1 == .west {
            board[snake.first!.x][snake.first!.y] = .snake(.northEast, .north)
        }
        moveWholeSnake()
    }
    
    @objc func swipedDown() {
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .south && tuple.1 != .north else { return }
        if tuple.1 == .east {
            board[snake.first!.x][snake.first!.y] = .snake(.southWest, .south)
        } else if tuple.1 == .west {
            board[snake.first!.x][snake.first!.y] = .snake(.southEast, .south)
        }
        moveWholeSnake()
    }
    
    @objc func swipedLeft() {
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .east && tuple.1 != .west else { return }
        if tuple.1 == .north {
            board[snake.first!.x][snake.first!.y] = .snake(.southWest, .west)
        } else if tuple.1 == .south {
            board[snake.first!.x][snake.first!.y] = .snake(.northWest, .west)
        }
        moveWholeSnake()
    }
    
    @objc func swipedRight() {
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!
        guard tuple.1 != .east && tuple.1 != .west else { return }
        if tuple.1 == .north {
            board[snake.first!.x][snake.first!.y] = .snake(.southEast, .east)
        } else if tuple.1 == .south {
            board[snake.first!.x][snake.first!.y] = .snake(.northEast, .east)
        }
        moveWholeSnake()
    }
}
