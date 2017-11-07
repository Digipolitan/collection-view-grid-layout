//
//  PathCollectionViewCell.swift
//  CollectionViewGridLayoutSample-iOS
//
//  Created by Benoit BRIATTE on 07/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

public class PathCollectionViewCell: UICollectionViewCell {

    public static let identifier: String = "PCVCRI"

    @IBOutlet var textLabel: UILabel!

    public func setIndexPath(_ indexPath: IndexPath) {
        self.textLabel.text = "[\(indexPath.section), \(indexPath.item)]"
    }

}
