import SpriteKit
import GoogleMobileAds
import SwiftyUtils

class GameScene: SKScene, GameSystemDelegate, GADInterstitialDelegate {
    var gameSystem: GameSystem!
    var upRecog: UISwipeGestureRecognizer!
    var downRecog: UISwipeGestureRecognizer!
    var leftRecog: UISwipeGestureRecognizer!
    var rightRecog: UISwipeGestureRecognizer!
    
    var newGameButton: ButtonNode!
    var pauseButton: ButtonNode!
    var pauseLabel: SKLabelNode!
    var highscoreDisplay: SKSpriteNode!
    var highscoreLabel: SKLabelNode!
    var scoreDisplay: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var interstitialAd: GADInterstitial!
    
    override func didMove(to view: SKView) {
        isUserInteractionEnabled = false
        newGameButton = childNode(withName: "newGameButton") as! ButtonNode
        pauseButton = childNode(withName: "pauseButton") as! ButtonNode
        pauseLabel = pauseButton.childNode(withName: "pauseLabel") as! SKLabelNode
        highscoreDisplay = childNode(withName: "highscoreDisplay") as! SKSpriteNode
        highscoreLabel = highscoreDisplay.childNode(withName: "highscoreValueLabel") as! SKLabelNode
        scoreDisplay = childNode(withName: "scoreDisplay") as! SKSpriteNode
        scoreLabel = scoreDisplay.childNode(withName: "scoreValueLabel") as! SKLabelNode
        
        let viewCoords = CGPoint(x: 0, y: 11)
        let sceneCoords = view.convert(viewCoords, to: self)
        newGameButton.position = CGPoint(x: newGameButton.position.x, y: sceneCoords.y)
        pauseButton.position = CGPoint(x: pauseButton.position.x, y: sceneCoords.y)
        highscoreDisplay.position = CGPoint(x: highscoreDisplay.position.x, y: sceneCoords.y)
        scoreDisplay.position = CGPoint(x: scoreDisplay.position.x, y: sceneCoords.y)
        highscoreLabel.text = String(UserDefaults.standard.integer(forKey: "highscore"))
        pauseButton.alpha = 0
        
        newGameButton.setTarget(self, selector: #selector(newGameTapped))
        pauseButton.setTarget(self, selector: #selector(pauseTapped))
        
        interstitialAd = GADInterstitial(adUnitID: adUnitId)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitialAd.load(request)
        interstitialAd.delegate = self
    }
    
    func didGameOver(gameSystem: GameSystem) {
        
        gameSystem.showGameOverScreen()
        self.gameSystem = nil
        newGameButton.run(SKAction.fadeIn(withDuration: 0.2))
        pauseButton.run(SKAction.fadeOut(withDuration: 0.2))
        
        if Int.random(0, 20) < 7 {
            interstitialAd.present(fromRootViewController: UIApplication.shared.topViewController()!)
        }
    }
    
    func scoreDidChange(newScore: Int) {
        scoreLabel.text = "\(newScore)"
    }
    
    func highscoreDidChange(newHighscore: Int) {
        highscoreLabel.text = "\(newHighscore)"
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        interstitialAd = GADInterstitial(adUnitID: adUnitId)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitialAd.load(request)
        interstitialAd.delegate = self
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        interstitialAd = GADInterstitial(adUnitID: adUnitId)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitialAd.load(request)
        interstitialAd.delegate = self
    }
    
    func initializeNewGame() {
        func calculateBoardSize() -> CGFloat {
            let startPointInScene = self.view!.convert(CGPoint.zero, to: self)
            let endPointInScene = self.view!.convert(CGPoint(x: 0, y: self.view!.frame.height), to: self)
            let actualHeightOfScene = abs(startPointInScene.y - endPointInScene.y)
            if actualHeightOfScene < 881 {
                return actualHeightOfScene - 131
            } else {
                return 750
            }
        }
        
        func calculateBoardPosition(boardSize: CGFloat) -> CGPoint {
            let startPointInScene = self.view!.convert(CGPoint.zero, to: self)
            let endPointInScene = self.view!.convert(CGPoint(x: 0, y: self.view!.frame.height), to: self)
            let actualHeightOfScene = abs(startPointInScene.y - endPointInScene.y)
            if boardSize < 750 {
                return CGPoint(x: 0, y: -(actualHeightOfScene / 2 - boardSize / 2 - 11))
            } else if actualHeightOfScene / 2 >= 120 {
                return CGPoint.zero
            } else {
                return CGPoint(x: 0, y: -(120 - actualHeightOfScene / 2))
            }
        }
        childNode(withName: "gameBoard")?.removeFromParent()
        scoreLabel.text = "0"
        
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
        
    }
    
    func newGameTapped() {
        initializeNewGame()
        gameSystem.startGame()
        newGameButton.run(SKAction.fadeOut(withDuration: 0.2))
        pauseButton.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    func pauseTapped() {
        guard let gameSystem = self.gameSystem else { return }
        guard gameSystem.hasStarted else { return }
        if gameSystem.isPaused {
            pauseLabel.text = "PAUSE"
        } else {
            pauseLabel.text = "RESUME"
        }
        gameSystem.pause()
    }
}
