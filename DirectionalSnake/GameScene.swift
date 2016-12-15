import SpriteKit

class GameScene: SKScene {
    var bg: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        bg = self.childNode(withName: "bg") as! SKSpriteNode
        
        let system = GameSystem(boardSize: 750)
        bg.addChild(system.boardNode)
    }
}
