//
//  MainCoordinator.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation
import UIKit

protocol MainCoordinatorProtocol: Coordinator {
    func showStats(logs: [NodeAction]) -> StatsViewModelProtocol
}

struct MainCoordinator: MainCoordinatorProtocol {
    let weakViewController: WeakReference<UIViewController>
    func showStats(logs: [NodeAction]) -> StatsViewModelProtocol {
        let viewController = StatsViewController()
        let coordinator = DefaultCoordinator(weakViewController: .init(viewController))
        let viewModel = StatsViewModel(coordinator: coordinator, logs: logs)
        viewController.viewModel = viewModel

        present(viewController)
        return viewModel
    }
}
