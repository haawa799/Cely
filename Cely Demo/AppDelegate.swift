//
//  AppDelegate.swift
//  Cely Demo
//
//  Created by Fabian Buentello on 10/15/16.
//  Copyright © 2016 Fabian Buentello. All rights reserved.
//

import UIKit
import Cely
import Locksmith

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Cely.setup(with: window!, forModel: User(), requiredProperties: [.token], withOptions: [
          .loginCompletionBlock: { (username: String, password: String, viewController: UIViewController?) in
                if username == "asdf" && password == "asdf" {
                    Cely.save(username, forKey: "username")
                    Cely.save("FAKETOKEN:\(username)\(password)", forKey: "token", securely: true)
                    Cely.changeStatus(to: .loggedIn)
                }
            }
            ])

        return true
    }
}
