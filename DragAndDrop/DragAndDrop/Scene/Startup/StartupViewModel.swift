//
//  StartupViewModel.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation

import Foundation

protocol StartupViewModelProtocol {
    func showRootController()
}

final class StartupViewModel<CoordinatorType: StartupCoordinatorProtocol>: StartupViewModelProtocol, CoordinatedViewModel {

    let coordinator: CoordinatorType

    init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

    func showRootController() {
        coordinator.showRootScene()
    }
}
