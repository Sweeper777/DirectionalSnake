import Foundation

protocol GameSystemDelegate: NSObjectProtocol {
    func didGameOver(gameSystem: GameSystem)
    
    func scoreDidChange(newScore: Int)
    
    func highscoreDidChange(newHighscore: Int)
    
}
