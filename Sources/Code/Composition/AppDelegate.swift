//
// Copyright © 2018 Smirnov Maxim. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let appFactory = AppFactory()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setup()
        return true
    }

    private func setup() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appFactory.sceneFactory.makeCurrencyScene()
        window?.makeKeyAndVisible()
    }
}
