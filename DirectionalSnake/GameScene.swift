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
        view!.gestureRecognizers?.removeAll()
        
        gameSystem = GameSystem(boardSize: 750)
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
