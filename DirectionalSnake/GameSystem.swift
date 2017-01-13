import SpriteKit
import SwiftRandom

class GameSystem {
    var board: [[BoardState]]
    let boardNode: SKSpriteNode
    let snakeSize: CGFloat
    var snake: [SnakeBody] = []
    var currentFood: Food?
    var canChangeDirection = true
    var hasStarted = false
    var highscoreUpdated = false
    var justAteFood = false
    var isPaused = false
    weak var delegate: GameSystemDelegate?
    
    var gameOverLabel: SKSpriteNode!
    var newHighscoreLabel: SKSpriteNode!
    
    var score = 0 {
        willSet {
            delegate?.scoreDidChange(newScore: newValue)
            if newValue > highscore {
                highscore = newValue
                highscoreUpdated = true
            }
        }
    }
    
    var highscore = UserDefaults.standard.integer(forKey: "highscore") {
        willSet {
            UserDefaults.standard.set(newValue, forKey: "highscore")
            delegate?.highscoreDidChange(newHighscore: newValue)
        }
    }
    
    init(boardSize: CGFloat) {
        snakeSize = floor(boardSize / 20)
        board = [[BoardState]](repeating: [BoardState](repeating: .empty, count: 20), count: 20)
        boardNode = SKSpriteNode(color: UIColor(hex: "8dee8d"), size: CGSize(width: snakeSize * 20, height: snakeSize * 20))
        boardNode.zPosition = 999
        boardNode.position = CGPoint(x: snakeSize * -10, y: snakeSize * -10)
        boardNode.anchorPoint = CGPoint.zero
        boardNode.name = "gameBoard"
        
        gameOverLabel = SKSpriteNode(imageNamed: "gameOverBanner")
        gameOverLabel.alpha = 0
        let x = boardNode.frame.width / 2
        let y = boardNode.frame.height - 300
        gameOverLabel.zPosition = 1000
        gameOverLabel.position = CGPoint(x: x, y: y)
        boardNode.addChild(gameOverLabel)
        
        newHighscoreLabel = SKSpriteNode(imageNamed: "newHighscoreBanner")
        newHighscoreLabel.alpha = 0
        newHighscoreLabel.position = CGPoint(x: boardNode.frame.width / 2, y: boardNode.frame.height / 2 - 100)
        newHighscoreLabel.zPosition = 1000
        boardNode.addChild(newHighscoreLabel)
    }
    
    func startGame() {
        guard !hasStarted else { return }
        
        snake.append(SnakeBody(x: 0, y: 0, nodeSize: snakeSize, orientation: .northEast))
        boardNode.addChild(snake[0].node)
        
        board[0][0] = .snake(.northEast, .east)
        
        let runCodeAction = SKAction.run {
            [unowned self] in
            if self.justAteFood {
                self.increaseSnakeLength()
                self.justAteFood = false
                return
            }
            
            self.moveWholeSnake()
        }
        boardNode.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.25), runCodeAction])))
        
        generateFood()
        
        hasStarted = true
    }
    
    func pause() {
        if isPaused {
            isPaused = false
            boardNode.isPaused = false
        } else {
            isPaused = true
            boardNode.isPaused = true
        }
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
            let foodOrientation: Orientation = [Orientation.horizontal, .horizontal, .northEast, .northWest, .southEast, .southWest, .vertical, .vertical].randomItem()!
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
            var canEatFood = false
            switch getOrientationAndDirectionOfSnakeBody(snakeBody: snake.first!)!.1 {
            case .north:
                canEatFood = [.southEast, .southWest, .vertical].contains(orientation)
            case .south:
                canEatFood = [.northEast, .northWest, .vertical].contains(orientation)
            case .east:
                canEatFood = [.southWest, .northWest, .horizontal].contains(orientation)
            case .west:
                canEatFood = [.southEast, .northEast, .horizontal].contains(orientation)
            }
            if !canEatFood {
                gameOver()
                return
            }
            
            currentFood!.node.removeFromParent()
            justAteFood = true
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
        score += 1
    }
    
    func getOrientationAndDirectionOfSnakeBody(snakeBody: SnakeBody) -> (Orientation, Direction)? {
        guard case .snake(let orientation, let direction) = board[snakeBody.x][snakeBody.y] else { return nil }
        return (orientation, direction)
    }
    
    @objc func swipedUp() {
        guard let firstSnake = snake.first else { return }
        
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: firstSnake)!
        guard tuple.1 != .south && tuple.1 != .north else { return }
        if tuple.1 == .east {
            board[firstSnake.x][firstSnake.y] = .snake(.northWest, .north)
            firstSnake.updateOrientation(to: .northWest)
        } else if tuple.1 == .west {
            board[firstSnake.x][firstSnake.y] = .snake(.northEast, .north)
            firstSnake.updateOrientation(to: .northEast)
        }
    }
    
    @objc func swipedDown() {
         guard let firstSnake = snake.first else { return }
        
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: firstSnake)!
        guard tuple.1 != .south && tuple.1 != .north else { return }
        if tuple.1 == .east {
            board[firstSnake.x][firstSnake.y] = .snake(.southWest, .south)
            firstSnake.updateOrientation(to: .southWest)
        } else if tuple.1 == .west {
            board[firstSnake.x][firstSnake.y] = .snake(.southEast, .south)
            firstSnake.updateOrientation(to: .southEast)
        }
    }
    
    @objc func swipedLeft() {
        guard let firstSnake = snake.first else { return }
        
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: firstSnake)!
        guard tuple.1 != .east && tuple.1 != .west else { return }
        if tuple.1 == .north {
            board[firstSnake.x][firstSnake.y] = .snake(.southWest, .west)
            firstSnake.updateOrientation(to: .southWest)
        } else if tuple.1 == .south {
            board[firstSnake.x][firstSnake.y] = .snake(.northWest, .west)
            firstSnake.updateOrientation(to: .northWest)
        }
    }
    
    @objc func swipedRight() {
        guard let firstSnake = snake.first else { return }
        
        guard canChangeDirection else { return }
        canChangeDirection = false
        
        let tuple = getOrientationAndDirectionOfSnakeBody(snakeBody: firstSnake)!
        guard tuple.1 != .east && tuple.1 != .west else { return }
        if tuple.1 == .north {
            board[firstSnake.x][firstSnake.y] = .snake(.southEast, .east)
            firstSnake.updateOrientation(to: .southEast)
        } else if tuple.1 == .south {
            board[firstSnake.x][firstSnake.y] = .snake(.northEast, .east)
            firstSnake.updateOrientation(to: .northEast)
        }
    }
    
    func gameOver() {
        boardNode.removeAllActions()
        
        for child in boardNode.children.dropLast() {
            child.run(SKAction.fadeOut(withDuration: 1))
        }
        boardNode.children.last!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.run {
                [unowned self] in self.delegate?.didGameOver(gameSystem: self)
            }]))
    }
    
    func showGameOverScreen() {
        gameOverLabel.run(SKAction.fadeIn(withDuration: 0.2))
        
        if highscoreUpdated {
            newHighscoreLabel.run(SKAction.fadeIn(withDuration: 0.2))
        }
    }
}
