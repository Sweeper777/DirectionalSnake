import SpriteKit
import EZSwiftExtensions

class GameScene: SKScene, GameSystemDelegate {
    var gameSystem: GameSystem!
    var upRecog: UISwipeGestureRecognizer!
    var downRecog: UISwipeGestureRecognizer!
    var leftRecog: UISwipeGestureRecognizer!
    var rightRecog: UISwipeGestureRecognizer!
    
    override func didMove(to view: SKView) {
        
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
        view!.gestureRecognizers?.removeAll()
        
        let boardSize = calculateBoardSize()
        gameSystem = GameSystem(boardSize: boardSize)
        gameSystem.delegate = self
        bg.addChild(gameSystem.boardNode)
        
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
    }
}
