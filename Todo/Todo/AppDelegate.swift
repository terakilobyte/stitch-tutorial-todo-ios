//
//  AppDelegate.swift
//  Todo
//
//  Created by Nathan Leniz on 5/16/19.
//  Copyright © 2019 mongodb. All rights reserved.
//

import UIKit
import StitchCore
import StitchRemoteMongoDBService
import GoogleSignIn

// set up the Stitch client
let stitch = try! Stitch.initializeAppClient(withClientAppID: Constants.STITCH_APP_ID)

var itemsCollection: RemoteMongoCollection<TodoItem>!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // set up remote mongo client
        let MongoClient = try! stitch.serviceClient(fromFactory: remoteMongoClientFactory, withName: Constants.ATLAS_SERVICE_NAME)

        // set up remote mongo database and our collection handle
        itemsCollection = MongoClient.db(Constants.TODO_DATABASE).collection(Constants.TODO_ITEMS_COLLECTION, withCollectionType: TodoItem.self)
        
        // google sign-in
        GIDSignIn.sharedInstance()?.clientID = Constants.GOOGLE_CLIENT_ID
        GIDSignIn.sharedInstance()?.serverClientID = Constants.GOOGLE_SERVER_CLIENT_ID
        GIDSignIn.sharedInstance()?.delegate = self

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
        return true
    }
    
    // added for google sign-in
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("error received when logging in with Google: \(error.localizedDescription)")
        } else {
            switch user.serverAuthCode {
            case .some:
                let googleCredential = GoogleCredential.init(withAuthCode: user.serverAuthCode)
                stitch.auth.login(withCredential: googleCredential) { result in
                    switch result {
                    case .success:
                        print("successfully signed in with Google")
                        NotificationCenter.default.post(name: Notification.Name("OAUTH_SIGN_IN"), object: nil, userInfo: nil)
                    case .failure(let error):
                        print("failed logging in Stitch with Google. error: \(error)")
                        GIDSignIn.sharedInstance().signOut()
                    }
                }
            case .none:
                print("serverAuthCode not retreived")
                GIDSignIn.sharedInstance()?.signOut()
            }
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
