//
//  GameViewController.swift
//  DirectionalSnake
//
//  Created by Mulang Su on 11/12/2016.
//  Copyright © 2016 Mulang Su. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    let audioPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Spin it again", withExtension: "wav")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            
            audioPlayer.play()
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
