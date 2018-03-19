//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import UIKit
import SpriteKit
import Allow2

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {

    @IBOutlet var allow2PairButton : UIButton?
    var allow2BlockViewController: Allow2BlockViewController!
    var allow2LoginViewController: Allow2LoginViewController!

    @IBOutlet var pairView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
        
        print("Setting up Allow2 views…")
        
        allow2LoginViewController = Allow2.allow2LoginViewController
        allow2LoginViewController.view.isHidden = true
        view.addSubview(allow2LoginViewController.view)
        
        allow2BlockViewController = Allow2.allow2BlockViewController
        allow2BlockViewController.view.isHidden = true
        view.addSubview(allow2BlockViewController.view)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}

extension GameViewController: Allow2PairingViewControllerDelegate {
    
    func showPairView() {
        pairView?.isHidden = Allow2.shared.isPaired
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showPairView()
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.Allow2CheckResultNotification(notification:)), name: NSNotification.Name.allow2CheckResultNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.allow2CheckResultNotification, object: nil)
    }
    
    @IBAction func allow2Pair() {
        if let viewController = Allow2PairingViewController.instantiate() {
            viewController.delegate = self
            let navController = UINavigationController(rootViewController: viewController)
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(GameViewController.cancelPairing))
            self.present(navController, animated: true)
        }
    }
    
    @objc func cancelPairing() {
        self.dismiss(animated: true)
    }
    
    func Allow2PairingCompleted(result: Allow2Response) {
        DispatchQueue.main.async {
            switch result {
            case .PairResult(let result):
                print("paired \(result)")
                (UIApplication.shared.delegate as! AppDelegate).checkAllow2()
                self.presentedViewController?.dismiss(animated: true)
                break
            case .Error(let error):
                let err = error as NSError
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present( alert, animated: true, completion: nil )
                self.presentedViewController?.present(alert, animated: true, completion: nil)
                return
            default:
                break // cannot happen
            }
        }
    }
    
    @objc func Allow2CheckResultNotification(notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            let result  = userInfo["result"] as? Allow2CheckResult else {
                print("No Allow2CheckResult found in notification")
                return
        }
        
        DispatchQueue.main.async {
            self.showPairView()
            if (!result.allowed) {
                // configure the block screen to explain the issue
                self.allow2BlockViewController.checkResult(checkResult: result)
            }
            self.allow2BlockViewController.view.isHidden = !Allow2.shared.isPaired || (Allow2.shared.childId == nil) || result.allowed
            self.allow2LoginViewController.view.isHidden = !Allow2.shared.isPaired || (Allow2.shared.childId != nil)
            if (Allow2.shared.childId == nil) {
                self.allow2LoginViewController.newChildren()
            }
        }
    }
    
}
