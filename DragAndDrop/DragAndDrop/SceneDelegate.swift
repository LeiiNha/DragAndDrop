//
//  SceneDelegate.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var windowScene: UIWindowScene?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        windowScene = scene as? UIWindowScene
        startApp()
    }

    func startApp() {
        window = UIWindow()
        window?.windowScene = windowScene
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
        window?.makeKeyAndVisible()
    }
}
