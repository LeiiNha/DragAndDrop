//
//  StatsViewModel.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 15/08/2021.
//

import Foundation
import Combine

protocol StatsViewModelProtocol {
    var triangleCount: Int { get }
    var squareCount: Int { get }
    var circleCount: Int { get }
}

final class StatsViewModel<CoordinatorType: DefaultCoordinatorProtocol>: CoordinatedViewModel, StatsViewModelProtocol {
    let coordinator: CoordinatorType
    private var subscriptions: Set<AnyCancellable> = .init()

    private var actionsLog: [NodeAction]

    init(coordinator: CoordinatorType, logs: [NodeAction]) {
        self.coordinator = coordinator
        self.actionsLog = logs
    }

    var triangleCount: Int {
        5
    }

    var squareCount: Int {
        4
    }
    var circleCount: Int {
        3
    }
}
