//
//  WeakReference.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation

public struct WeakReference<T: AnyObject> {
    public private(set) weak var object: T?
    public init(_ ref: T? = nil) {
        object = ref
    }
}
