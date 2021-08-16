//
//  StatsTableViewCell.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 16/08/2021.
//

import UIKit

final class StatsTableViewCell: UITableViewCell {
    static let identifier = "StatsTableViewCell"

    func configure(name: String, count: Int) {
        let label = UILabel()
        label.text = "\(name) count: \(count.description)"
        contentView.addSubview(label, anchors: [.centerX(0), .centerY(0)])
    }
}
