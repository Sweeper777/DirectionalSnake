import SpriteKit

class GameScene: SKScene {
    var bg: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        bg = self.childNode(withName: "bg") as! SKSpriteNode
        
    }
}
