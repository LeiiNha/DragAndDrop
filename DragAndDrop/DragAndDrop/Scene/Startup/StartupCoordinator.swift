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
    func showStatsScreen()
}

struct StartupCoordinator: StartupCoordinatorProtocol {
    let weakViewController: WeakReference<UINavigationController>
    init(weakViewController: WeakReference<ViewController>) {
        self.weakViewController = weakViewController
    }

    func showStatsScreen() {
//        let viewController = OnboardingViewController()
//        let onboardingCoordinator = OnboardingCoordinator(weakViewController: .init(viewController))
//        let onboardingViewModel = OnboardingViewModel(coordinator: onboardingCoordinator)
//        viewController.viewModel = onboardingViewModel
//
//        guard let window = UIApplication.shared.windows.first else {
//            fatalError("Could not retreive app window")
//        }
//
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
//        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().backgroundColor = .clear
//        UIView.transition(with: window, duration: 0.4, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
//            self.viewController?.setViewControllers([viewController], animated: false)
//        })
    }

    func showRootScene() {
        let viewController = MainViewController()
        let coordinator = MainCoordinator(weakViewController: .init(viewController))
        let viewModel = MainViewModel(coordinator: coordinator)
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
