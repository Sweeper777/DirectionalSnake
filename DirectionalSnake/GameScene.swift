import SpriteKit

class GameScene: SKScene {
    var bg: SKSpriteNode!
    var gameSystem: GameSystem!
    var upRecog: UISwipeGestureRecognizer!
    var downRecog: UISwipeGestureRecognizer!
    var leftRecog: UISwipeGestureRecognizer!
    var rightRecog: UISwipeGestureRecognizer!
    
    override func didMove(to view: SKView) {
        bg = self.childNode(withName: "bg") as! SKSpriteNode
        
        gameSystem = GameSystem(boardSize: 750)
        bg.addChild(gameSystem.boardNode)
        
        upRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedUp))
        upRecog.direction = .up
        
        downRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedDown))
        downRecog.direction = .down
        
        leftRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedLeft))
        leftRecog.direction = .left
        
        rightRecog = UISwipeGestureRecognizer(target: gameSystem, action: #selector(GameSystem.swipedRight))
        rightRecog.direction = .right
        
        view.addGestureRecognizer(upRecog)
        view.addGestureRecognizer(downRecog)
        view.addGestureRecognizer(leftRecog)
        view.addGestureRecognizer(rightRecog)
    }
}
