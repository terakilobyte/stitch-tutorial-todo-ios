//
//  ViewController.swift
//  Todo
//
//  Created by Nathan Leniz on 5/16/19.
//  Copyright © 2019 mongodb. All rights reserved.
//

import UIKit
import MongoSwift
import StitchCore
import FBSDKLoginKit
import FacebookCore
import FacebookLogin

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Welcome"
        // add self as observer to NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(didSignIn), name: NSNotification.Name("SIGN_IN"), object: nil)
        // Do any additional setup after loading the view.
        
        if stitch.auth.isLoggedIn {
            self.navigationController?.pushViewController(TodoTableViewController(), animated: true)
        } else {
            
            let anonymousButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - 150, y: 100, width: 300, height: 50))
            anonymousButton.backgroundColor = .green
            anonymousButton.setTitle("Login Anonymously", for: .normal)
            anonymousButton.addTarget(self, action: #selector(didClickAnonymousLogin), for: .touchUpInside)
            

            let fbButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - 150, y: 300, width: 300, height: 50))
            fbButton.backgroundColor = .darkGray
            fbButton.setTitle("Login with Facebook", for: .normal)
            fbButton.addTarget(self, action: #selector(didClickFacebookLogin), for: .touchUpInside)
            
            
            self.view.addSubview(anonymousButton)
            self.view.addSubview(fbButton)
            
        }
    }
    
    
    @objc func didClickFacebookLogin(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { result in
            switch result {
            case .failed(let error):
                print(error.localizedDescription)
            case .cancelled:
                print("cancelled")
            case .success(_, _, let accessToken):
                let fbCredential = FacebookCredential.init(withAccessToken: accessToken.tokenString)
                stitch.auth.login(withCredential: fbCredential) { result in
                    switch result {
                    case .success:
                        NotificationCenter.default.post(name: Notification.Name("SIGN_IN"), object: nil, userInfo: nil)
                    case .failure(let error):
                        print("failed logging in Stitch with Facebook. error: \(error)")
                        LoginManager().logOut()
                    }
                }
            }
        }
    }

    
    @objc func didClickAnonymousLogin(_ sender: Any) {
        stitch.auth.login(withCredential: AnonymousCredential()) { result in
            switch result {
            case .failure(let e):
                fatalError(e.localizedDescription)
            case .success:
                NotificationCenter.default.post(name: Notification.Name("SIGN_IN"), object: nil, userInfo: nil)

            }
        }
    }
    
    @objc func didSignIn(_sender: Any) {
        DispatchQueue.main.sync {
            self.navigationController?.pushViewController(TodoTableViewController(), animated: true)
        }
    }
}
