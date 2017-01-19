//
//  CelyManager.swift
//  Cely
//
//  Created by Fabian Buentello on 10/14/16.
//  Copyright © 2016 Fabian Buentello. All rights reserved.
//

import Foundation

public protocol CelyWindowManagerDelegate: class {
  var shouldTryUsingMainStoryboard: Bool { get }
  func presentingCallback(window: UIWindow, status: CelyStatus)
}

public class CelyWindowManager {

    // MARK: - Variables
    static let manager = CelyWindowManager()
    internal var window: UIWindow!

    public var loginStoryboard: UIStoryboard!
    public lazy var homeStoryboard: UIStoryboard? = {
        guard (self.delegate?.shouldTryUsingMainStoryboard == true) || (self.delegate == nil) else { return nil }
        let notTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil
        let homeStoryboard = notTesting ?
            UIStoryboard(name: "Main", bundle: Bundle.main) :
            UIStoryboard(name: "TestMain", bundle: Bundle(for: type(of: self)))
        return homeStoryboard
    }()
    public var loginStyle: CelyStyle!

    weak var delegate: CelyWindowManagerDelegate?

    private init() {
        loginStoryboard = UIStoryboard(name: "Cely", bundle: Bundle(for: type(of: self)))
    }

    static func setup(delegate: CelyWindowManagerDelegate? = nil, window _window: UIWindow, withOptions options: [CelyOptions : Any?]? = [:]) {
        CelyWindowManager.manager.window = _window
        CelyWindowManager.manager.delegate = delegate

        // Set the login Styles
        CelyWindowManager.manager.loginStyle = options?[.loginStyle] as? CelyStyle ?? DefaultSyle()

        // Set the HomeStoryboard
        CelyWindowManager.setHomeStoryboard(options?[.homeStoryboard] as? UIStoryboard)

        // Set the LoginStoryboard
        CelyWindowManager.setLoginStoryboard(options?[.loginStoryboard] as? UIStoryboard)

        CelyWindowManager.manager.addObserver(#selector(showScreenWith), action: .loggedIn)
        CelyWindowManager.manager.addObserver(#selector(showScreenWith), action: .loggedOut)
    }

    // MARK: - Private Methods

    private func addObserver(_ selector: Selector, action: CelyStatus) {
        NotificationCenter.default
            .addObserver(self,
                         selector: selector,
                         name: NSNotification.Name(rawValue: action.rawValue),
                         object: nil)
    }

    // MARK: - Public Methods

    @objc func showScreenWith(notification: NSNotification) {
        if let status = notification.object as? CelyStatus {
            CelyWindowManager.manager.delegate?.presentingCallback(window: CelyWindowManager.manager.window, status: status)
            let useStoryboard = CelyWindowManager.manager.delegate?.shouldTryUsingMainStoryboard ?? true
            if status == .loggedIn {
                guard let homeStoryboard = CelyWindowManager.manager.homeStoryboard, useStoryboard == true else { return }
                changeRootViewController(window: CelyWindowManager.manager.window, viewController: homeStoryboard.instantiateInitialViewController())
            } else {
              changeRootViewController(window: CelyWindowManager.manager.window, viewController: CelyWindowManager.manager.loginStoryboard.instantiateInitialViewController())
            }
        }
    }

    //http://stackoverflow.com/questions/7703806/rootviewcontroller-switch-transition-animation
    func changeRootViewController(window: UIWindow, viewController: UIViewController?) {
      guard let viewController = viewController else { return }
      guard let snapshot: UIView = (window.snapshotView(afterScreenUpdates: true)) else { return }
      viewController.view.addSubview(snapshot)
      window.rootViewController = viewController
      UIView.animate(withDuration: 0.3, animations: {() in
        snapshot.layer.opacity = 0
        snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
      }, completion: { ( _: Bool) in
        snapshot.removeFromSuperview()
      })
    }

    static func setHomeStoryboard(_ storyboard: UIStoryboard?) {
        CelyWindowManager.manager.homeStoryboard = storyboard ?? CelyWindowManager.manager.homeStoryboard
    }

    static func setLoginStoryboard(_ storyboard: UIStoryboard?) {
        CelyWindowManager.manager.loginStoryboard = storyboard ?? CelyWindowManager.manager.loginStoryboard
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
