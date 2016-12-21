import SpriteKit
import EZSwiftExtensions

class GameScene: SKScene, GameSystemDelegate {
    var gameSystem: GameSystem!
    var upRecog: UISwipeGestureRecognizer!
    var downRecog: UISwipeGestureRecognizer!
    var leftRecog: UISwipeGestureRecognizer!
    var rightRecog: UISwipeGestureRecognizer!
    
    var newGameButton: SKSpriteNode!
    var highscoreDisplay: SKSpriteNode!
    var highscoreLabel: SKLabelNode!
    var scoreDisplay: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        newGameButton = childNode(withName: "newGameButton") as! SKSpriteNode
        highscoreDisplay = childNode(withName: "highscoreDisplay") as! SKSpriteNode
        highscoreLabel = highscoreDisplay.childNode(withName: "highscoreValueLabel") as! SKLabelNode
        scoreDisplay = childNode(withName: "scoreDisplay") as! SKSpriteNode
        scoreLabel = scoreDisplay.childNode(withName: "scoreValueLabel") as! SKLabelNode
        
        let viewCoords = CGPoint(x: 0, y: 11)
        let sceneCoords = view.convert(viewCoords, to: self)
        newGameButton.position = CGPoint(x: newGameButton.position.x, y: sceneCoords.y)
        highscoreDisplay.position = CGPoint(x: highscoreDisplay.position.x, y: sceneCoords.y)
        scoreDisplay.position = CGPoint(x: scoreDisplay.position.x, y: sceneCoords.y)
        initializeNewGame()
    }
    
    func didGameOver(gameSystem: GameSystem) {
        self.gameSystem.boardNode.children.forEach { $0.removeFromParent() }
        self.gameSystem = nil
    }
    
    func initializeNewGame() {
        func calculateBoardSize() -> CGFloat {
            let startPointInScene = self.view!.convert(CGPoint.zero, to: self)
            let endPointInScene = self.view!.convert(CGPoint(x: 0, y: self.view!.h), to: self)
            let actualHeightOfScene = abs(startPointInScene.y - endPointInScene.y)
            if actualHeightOfScene < 881 {
                return actualHeightOfScene - 131
            } else {
                return 750
            }
        }
        
        func calculateBoardPosition(boardSize: CGFloat) -> CGPoint {
            let startPointInScene = self.view!.convert(CGPoint.zero, to: self)
            let endPointInScene = self.view!.convert(CGPoint(x: 0, y: self.view!.h), to: self)
            let actualHeightOfScene = abs(startPointInScene.y - endPointInScene.y)
            if boardSize < 750 {
                return CGPoint(x: 0, y: -(actualHeightOfScene / 2 - boardSize / 2 - 11))
            } else if actualHeightOfScene / 2 >= 120 {
                return CGPoint.zero
            } else {
                return CGPoint(x: 0, y: -(120 - actualHeightOfScene / 2))
            }
        }
        
        view!.gestureRecognizers?.removeAll()
        
        let boardSize = calculateBoardSize()
        gameSystem = GameSystem(boardSize: boardSize)
        gameSystem.delegate = self
        let boardPos = calculateBoardPosition(boardSize: boardSize)
        let actualBoardSize = gameSystem.boardNode.frame.width
        gameSystem.boardNode.position = CGPoint(x: boardPos.x - actualBoardSize / 2, y: boardPos.y - actualBoardSize / 2)
        self.addChild(gameSystem.boardNode)
        
        upRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedUp))
        upRecog.direction = .up
        
        downRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedDown))
        downRecog.direction = .down
        
        leftRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedLeft))
        leftRecog.direction = .left
        
        rightRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedRight))
        rightRecog.direction = .right
        
        view!.addGestureRecognizer(upRecog)
        view!.addGestureRecognizer(downRecog)
        view!.addGestureRecognizer(leftRecog)
        view!.addGestureRecognizer(rightRecog)
        
        gameSystem.startGame()
    }
}
