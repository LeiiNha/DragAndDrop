//
//  MainCollectionViewCell.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 16/08/2021.
//

import UIKit

final class MainCollectionViewCell: UICollectionViewCell {
    static let identifier = "MainCollectionViewCell"
    func configure(shape: Shape) {
        let label = UILabel()
        label.text = shape.text
        contentView.backgroundColor = shape.color
        contentView.addSubview(label, anchors: [.centerX(0), .centerY(0)])
    }
}
