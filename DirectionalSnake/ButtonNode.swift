import SpriteKit

class ButtonNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
        originalColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        originalColor = color
    }
    
    var originalColor: UIColor!
    var target: AnyObject?
    var selector: Selector?
    
    func setTarget(_ target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if texture == nil {
            let r = Float(originalColor.redComponent) / 255.0
            let g = Float(originalColor.greenComponent) / 255.0
            let b = Float(originalColor.blueComponent) / 255.0
            let newR = r + 0.2 > 1 ? 1 : r + 0.2
            let newG = g + 0.2 > 1 ? 1 : g + 0.2
            let newB = b + 0.2 > 1 ? 1 : b + 0.2
            color = UIColor(colorLiteralRed: newR, green: newG, blue: newB, alpha: 1)
        } else {
            run(SKAction.colorize(with: UIColor.black, colorBlendFactor: 0.5, duration: 0))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if texture == nil {
            color = originalColor
        } else {
            run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        }
        
        guard touches.contains(where: { (touch) -> Bool in
            let location = touch.location(in: self)
            let correctedLocation = CGPoint(x: location.x, y: -location.y)
            print(correctedLocation)
            return self.frame.width > correctedLocation.x && self.frame.height > correctedLocation.y
        }) else { return }
        
        if let target = self.target, let selector = self.selector {
            _ = target.perform(selector)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if texture == nil {
            color = originalColor
        } else {
            run(SKAction.colorize(withColorBlendFactor: 0, duration: 0))
        }
    }
}
