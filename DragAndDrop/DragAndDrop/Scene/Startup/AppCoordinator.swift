//
//  AppCoordinator.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import UIKit
import Combine

final class AppCoordinator {
    weak var window: UIWindow?
    private var subscriptions: Set<AnyCancellable> = .init()

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        let viewController = StartupViewController()
        let rootViewController = UINavigationController(rootViewController: viewController)
        let coordinator =  StartupCoordinator(weakViewController: .init(rootViewController))
        let viewModel = StartupViewModel(coordinator: coordinator)
        viewController.viewModel = viewModel
        window?.rootViewController = rootViewController
        rootViewController.setNavigationBarHidden(true, animated: false)
    }
}
