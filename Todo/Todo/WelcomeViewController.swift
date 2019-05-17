//
//  ViewController.swift
//  Todo
//
//  Created by Nathan Leniz on 5/16/19.
//  Copyright © 2019 mongodb. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Welcome"
        if stitch.auth.isLoggedIn {
            self.navigationController?.pushViewController(TodoTableViewController(), animated: true)
        } else {
            let alertController = UIAlertController(title: "Login to Stitch", message: "Anonymous Login", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { [unowned self] _ -> Void in
                stitch.auth.login(withCredential: AnonymousCredential()) { [weak self] result in
                    switch result {
                    case .failure(let e):
                        fatalError(e.localizedDescription)
                    case .success:
                        DispatchQueue.main.async {
                            self?.navigationController?.pushViewController(TodoTableViewController(), animated: true)
                        }
                    }
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
