import SpriteKit

enum BoardState {
    case empty
    case food(Orientation)
    case snake(Orientation, Direction)
}

enum Orientation {
    case horizontal
    case vertical
    case northWest
    case northEast
    case southEast
    case southWest
}

enum Direction {
    case north
    case east
    case south
    case west
}
