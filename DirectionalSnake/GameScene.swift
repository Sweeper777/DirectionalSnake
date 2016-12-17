import SpriteKit

class GameScene: SKScene {
    var bg: SKSpriteNode!
    var gameSystem: GameSystem!
    
    override func didMove(to view: SKView) {
        bg = self.childNode(withName: "bg") as! SKSpriteNode
        
        gameSystem = GameSystem(boardSize: 750)
        bg.addChild(gameSystem.boardNode)
        
    }
}
