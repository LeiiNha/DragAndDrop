//
//  Mock.swift
//  DragAndDropTests
//
//  Created by Erica Geraldes on 16/08/2021.
//

import Foundation
protocol Mock: AnyObject {
    associatedtype Method: Hashable, CaseIterable

    var callersCount: [Method: Int] { get set }

    func incrementCounterFor(_ function: Method)
}

extension Mock {
    func incrementCounterFor(_ function: Method) {
        guard let value = callersCount[function] else {
            callersCount[function] = 1
            return
        }

        callersCount[function] = value + 1
        debugPrint(String(describing: function))
    }

    func execute<T>(function: Method, mockedValue: T) -> T {
        incrementCounterFor(function)
        return mockedValue
    }

    func execute<T>(function: Method, mockedValue: T, completion: (T) -> Void) {
        incrementCounterFor(function)
        completion(mockedValue)
    }
}

extension Dictionary where Key: CaseIterable, Value == Int {
    static func initialized(count: Int = 0) -> Self {
        Key.allCases.reduce(into: [:]) { accumulator, key in
            accumulator[key] = count
        }
    }
}
