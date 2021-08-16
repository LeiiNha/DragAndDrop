//
//  StatsViewModel.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 15/08/2021.
//

import Foundation
import Combine

protocol StatsViewModelProtocol {
    var statsDetails: [StatsViewController.StatsDetails] { get }
    func removeShapes(shapes: [Shape])
    var removeShapesPublisher: AnyPublisher<[Shape], Never> { get }
}

final class StatsViewModel<CoordinatorType: DefaultCoordinatorProtocol>: CoordinatedViewModel, StatsViewModelProtocol {
    let coordinator: CoordinatorType
    private var subscriptions: Set<AnyCancellable> = .init()
    private let logs: [NodeAction]

    private(set) lazy var statsDetails: [StatsViewController.StatsDetails] = {
        var stats:  [StatsViewController.StatsDetails] = []
        Shape.allCases.forEach { [weak self] shape in
            guard let self = self else { return }
            let shapeStat = self.logs.filter { log in
                if case let .spawn(logShape, _) = log {
                    return logShape == shape
                }
                return false
            }
            stats.append(.init(count: shapeStat.count, shape: shape))
        }
        return stats
    }()

    init(coordinator: CoordinatorType, logs: [NodeAction]) {
        self.coordinator = coordinator
        self.logs = logs
    }

    private var removeShapesPassthrough: PassthroughSubject<[Shape], Never> = .init()
    var removeShapesPublisher: AnyPublisher<[Shape], Never> {
        removeShapesPassthrough.eraseToAnyPublisher()
    }

    func removeShapes(shapes: [Shape]) {
        removeShapesPassthrough.send(shapes)
        coordinator.dismiss()
    }
}
