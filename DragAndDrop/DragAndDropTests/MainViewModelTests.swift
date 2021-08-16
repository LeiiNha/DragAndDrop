//
//  MainViewModelTests.swift
//  DragAndDropTests
//
//  Created by Erica Geraldes on 16/08/2021.
//

import XCTest
@testable import DragAndDrop

class MainViewModelTests: XCTestCase {
    var uut: MainViewModel<CoordinatorMock>!

    func testSpawn() throws {
        let mockGameScene = GameSceneViewModelMock()
        uut = MainViewModel(coordinator: CoordinatorMock(), gameViewModel: mockGameScene)
        uut.spawn(shape: .circle)
        XCTAssertEqual(mockGameScene.callersCount[.spawn], 1)
    }

    func testUndoLastAction() throws {
        let mockGameScene = GameSceneViewModelMock()
        uut = MainViewModel(coordinator: CoordinatorMock(), gameViewModel: mockGameScene)
        uut.spawn(shape: .circle)
        uut.spawn(shape: .circle)
        XCTAssertEqual(mockGameScene.callersCount[.spawn], 2)
        uut.movedNode(previousX: 22.0, previousY: 11.0, uuid: "")
        XCTAssertEqual(mockGameScene.callersCount[.dragDrop], 1)
        uut.undoLastAction()
        XCTAssertEqual(mockGameScene.callersCount[.undoLastDragDrop], 1)
    }

    func testStatsPressed() {
        let mockGameScene = GameSceneViewModelMock()
        let coordinator = CoordinatorMock()
        uut = MainViewModel(coordinator: coordinator, gameViewModel: mockGameScene)
        uut.statsButtonPressed()
        XCTAssertEqual(coordinator.callersCount[.showStatScreen], 1)
    }

    func testMoveNode() {
        let mockGameScene = GameSceneViewModelMock()
        uut = MainViewModel(coordinator: CoordinatorMock(), gameViewModel: mockGameScene)
        uut.spawn(shape: .circle)
        XCTAssertEqual(mockGameScene.callersCount[.spawn], 1)
        uut.movedNode(previousX: 22.0, previousY: 11.0, uuid: "")
        XCTAssertEqual(mockGameScene.callersCount[.dragDrop], 1)
    }

    func testRemoveNode() {
        let mockGameScene = GameSceneViewModelMock()
        uut = MainViewModel(coordinator: CoordinatorMock(), gameViewModel: mockGameScene)
        uut.spawn(shape: .circle)
        XCTAssertEqual(mockGameScene.callersCount[.spawn], 1)
        uut.removeNode(uuid: "")
        XCTAssertEqual(mockGameScene.callersCount[.longTapRemove], 1)
    }
}
