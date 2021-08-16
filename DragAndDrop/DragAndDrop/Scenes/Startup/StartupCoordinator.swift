//
//  StartupCoordinator.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation
import UIKit

protocol StartupCoordinatorProtocol: Coordinator {
    func showRootScene()
}

struct StartupCoordinator: StartupCoordinatorProtocol {
    let weakViewController: WeakReference<UINavigationController>

    func showRootScene() {
        let viewController = MainViewController()
        let coordinator = MainCoordinator(weakViewController: .init(viewController))
        let viewModel = MainViewModel(coordinator: coordinator, gameViewModel: GameSceneViewModel())
        viewController.viewModel = viewModel

        guard let window = UIApplication.shared.windows.first else {
            fatalError("Could not retreive app window")
        }

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UIView.transition(with: window, duration: 0.4, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            self.viewController?.setViewControllers([viewController], animated: false)
        })
    }
}
