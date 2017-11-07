//
//  CollectionViewGridLayout.swift
//  CollectionViewGridLayout
//
//  Created by Benoit BRIATTE on 06/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

@objc public protocol CollectionViewDelegateGridLayout: UICollectionViewDelegate {
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       rowSpacingForSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       columnSpacingForSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       insetForSection section: Int) -> UIEdgeInsets
}

public struct CollectionViewGridLayout {

    private init() { }

    public struct SectionLayoutAttributes {
        public let items: [UICollectionViewLayoutAttributes]
        public let header: UICollectionViewLayoutAttributes?
        public let footer: UICollectionViewLayoutAttributes?

        public init(items: [UICollectionViewLayoutAttributes], header: UICollectionViewLayoutAttributes?, footer: UICollectionViewLayoutAttributes?) {
            self.items = items
            self.header = header
            self.footer = footer
        }
    }
}
