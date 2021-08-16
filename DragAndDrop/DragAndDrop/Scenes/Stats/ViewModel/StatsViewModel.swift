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
    func removeAllPressed()
    var removeAllPublisher: AnyPublisher<Void, Never> { get }
}

final class StatsViewModel<CoordinatorType: DefaultCoordinatorProtocol>: CoordinatedViewModel, StatsViewModelProtocol {
    let coordinator: CoordinatorType
    private var subscriptions: Set<AnyCancellable> = .init()

    private(set) var triangleCount: Int = 0
    private(set) var squareCount: Int = 0
    private(set) var circleCount: Int = 0

    init(coordinator: CoordinatorType, logs: [NodeAction]) {
        self.coordinator = coordinator
        logs.forEach { [weak self] log in
            if case let .spawn(shape, _ ) = log {
                switch shape {
                case .circle: self?.circleCount+=1
                case .square: self?.squareCount+=1
                case .triangle: self?.triangleCount+=1
                }
            }
        }
    }

    private var removeAllPassthrough: PassthroughSubject<Void, Never> = .init()
    var removeAllPublisher: AnyPublisher<Void, Never> {
        removeAllPassthrough.eraseToAnyPublisher()
    }

    func removeAllPressed() {
        removeAllPassthrough.send()
        coordinator.dismiss()
    }
}
