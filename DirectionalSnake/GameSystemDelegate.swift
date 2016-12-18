import Foundation

protocol GameSystemDelegate: NSObjectProtocol {
    func didGameOver(gameSystem: GameSystem)
}
