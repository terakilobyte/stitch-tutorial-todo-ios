//
//  AppDelegate.swift
//  Todo
//
//  Created by Nathan Leniz on 5/16/19.
//  Copyright © 2019 mongodb. All rights reserved.
//

import UIKit
// import StitchCore
import StitchCore
// import StitchRemoteMongoDBService
import StitchRemoteMongoDBService
import FBSDKLoginKit

// set up the Stitch client
let stitch = try! Stitch.initializeAppClient(withClientAppID: Constants.STITCH_APP_ID)

var itemsCollection: RemoteMongoCollection<TodoItem>!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // set up remote mongo client
        let MongoClient = try! stitch.serviceClient(fromFactory: remoteMongoClientFactory, withName: Constants.ATLAS_SERVICE_NAME)

        // set up remote mongo database and our collection handle
        itemsCollection = MongoClient.db(Constants.TODO_DATABASE).collection(Constants.TODO_ITEMS_COLLECTION, withCollectionType: TodoItem.self)

        // facebook sign-in
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)


        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
        return true
    }

    // added for google and facebook signin
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return  ApplicationDelegate.shared.application(app, open: url, options: options)
    }

}
