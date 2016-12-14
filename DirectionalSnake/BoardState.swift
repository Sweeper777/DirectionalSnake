import SpriteKit

enum BoardState {
    case empty
    case food(Orientation)
    case snake(Orientation)
}

enum Orientation: String {
    case horizontal
    case vertical
    case northWest
    case northEast
    case southEast
    case southWest
}
