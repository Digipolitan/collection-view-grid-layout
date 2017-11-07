//
//  CollectionReusableView.swift
//  CollectionViewGridLayoutSample-iOS
//
//  Created by Benoit BRIATTE on 07/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

public class CollectionReusableView: UICollectionReusableView {

    @IBOutlet var textLabel: UILabel!

    public static let identifier = "CRVRI"

    public func setIndexPath(_ indexPath: IndexPath, kind: String) {
        self.textLabel.text = "\(kind) [(\(indexPath.section), \(indexPath.item))]"
    }

}
