//
//  CollectionViewHorizontalGridLayout.swift
//  CollectionViewGridLayout
//
//  Created by Benoit BRIATTE on 05/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

@objc public protocol CollectionViewDelegateHorizontalGridLayout: CollectionViewDelegateGridLayout {

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       numberOfRowsForSection section: Int) -> Int

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       weightForRow row: Int,
                                       inSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       widthForItemAt indexPath: IndexPath,
                                       rowHeight: CGFloat) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       widthForHeaderInSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       widthForFooterInSection section: Int) -> CGFloat
}

open class CollectionViewHorizontalGridLayout: UICollectionViewLayout {

    public var itemWidth: CGFloat = Defaults.itemWidth {
        didSet {
            self.invalidateLayout()
        }
    }
    fileprivate var layoutAttributes: [CollectionViewGridLayout.SectionLayoutAttributes]!
    fileprivate var contentWidth: CGFloat!

    open override func prepare() {
        super.prepare()
        self.layoutAttributes = []
        guard let collectionView = self.collectionView else {
            self.contentWidth = 0
            return
        }
        var position: CGFloat = 0
        for section in 0 ..< collectionView.numberOfSections {
            self.layoutAttributes.append(self.prepareLayoutAttributes(for: collectionView, in: section, from: &position))
        }
        self.contentWidth = position
    }

    public func prepareLayoutAttributes(for collectionView: UICollectionView, in section: Int, from position: inout CGFloat) -> CollectionViewGridLayout.SectionLayoutAttributes {
        let gridLayoutDelegate = self.collectionView?.delegate as? CollectionViewDelegateHorizontalGridLayout
        var itemLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        let measureInfo = MeasureInfo(section: section, collectionView: collectionView, layout: self)
        var columnWidth: CGFloat = 0
        var rowIndex: Int = 0
        var itemFrame: CGRect = .zero
        let sectionInset = measureInfo.sectionInset
        let headerLayoutAttributes = self.prepareHeaderLayoutAttributes(for: collectionView, in: section, from: &position)
        position += sectionInset.left
        for column in 0 ..< measureInfo.numberOfColumns {
            if column > 0 {
                position += measureInfo.columnSpacing
            }
            columnWidth = 0
            rowIndex = 0
            let start = column * measureInfo.numberOfRows
            let end = min((column + 1) * measureInfo.numberOfRows, measureInfo.numberOfItems)
            for item in start ..< end {
                if rowIndex == measureInfo.numberOfRows {
                    rowIndex = 0
                }
                let indexPath = IndexPath(item: item, section: section)
                let itemWidth = gridLayoutDelegate?.collectionView?(collectionView, layout: self, widthForItemAt: indexPath, rowHeight: measureInfo.rowsHeight[rowIndex]) ?? self.itemWidth
                columnWidth = max(columnWidth, itemWidth)
                itemLayoutAttributes.append(UICollectionViewLayoutAttributes(forCellWith: indexPath))
                rowIndex += 1
            }
            rowIndex = 0
            var rowYPosition: CGFloat = sectionInset.top
            for item in start ..< end {
                if rowIndex == measureInfo.numberOfColumns {
                    rowIndex = 0
                }
                if rowIndex > 0 {
                    rowYPosition += measureInfo.rowSpacing
                }
                let rowHeight = measureInfo.rowsHeight[rowIndex]
                itemFrame.origin = CGPoint(x: position, y: rowYPosition)
                itemFrame.size = CGSize(width: columnWidth, height: rowHeight)
                itemLayoutAttributes[item].frame = itemFrame
                rowIndex += 1
                rowYPosition += rowHeight
            }
            position += columnWidth
        }
        position += sectionInset.right
        let footerLayoutAttributes = self.prepareFooterLayoutAttributes(for: collectionView, in: section, from: &position)
        return CollectionViewGridLayout.SectionLayoutAttributes(items: itemLayoutAttributes, header: headerLayoutAttributes, footer: footerLayoutAttributes)
    }

    public func prepareHeaderLayoutAttributes(for collectionView: UICollectionView, in section: Int, from position: inout CGFloat) -> UICollectionViewLayoutAttributes? {
        guard let gridLayoutDelegate = self.collectionView?.delegate as? CollectionViewDelegateHorizontalGridLayout else {
            return nil
        }
        let headerWidth = gridLayoutDelegate.collectionView?(collectionView, layout: self, widthForHeaderInSection: section) ?? 0
        if headerWidth > 0 {
            let headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
            headerLayoutAttributes.frame = CGRect(x: position, y: 0, width: headerWidth, height: collectionView.bounds.height)
            position += headerWidth
            return headerLayoutAttributes
        }
        return nil
    }

    public func prepareFooterLayoutAttributes(for collectionView: UICollectionView, in section: Int, from position: inout CGFloat) -> UICollectionViewLayoutAttributes? {
        guard let gridLayoutDelegate = self.collectionView?.delegate as? CollectionViewDelegateHorizontalGridLayout else {
            return nil
        }
        let footerWidth = gridLayoutDelegate.collectionView?(collectionView, layout: self, widthForFooterInSection: section) ?? 0
        if footerWidth > 0 {
            let footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
            footerLayoutAttributes.frame = CGRect(x: position, y: 0, width: footerWidth, height: collectionView.bounds.height)
            position += footerWidth
            return footerLayoutAttributes
        }
        return nil
    }

    open override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.collectionView?.bounds.height ?? 0)
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributesForElements(in: rect)
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributes[indexPath.section].items[indexPath.row]
    }

    private func attributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        let layoutAttributes = self.layoutAttributes.filter { (sectionLayoutAttributes) -> Bool in
            if let header = sectionLayoutAttributes.header, header.frame.intersects(rect) {
                return true
            }
            if let footer = sectionLayoutAttributes.footer, footer.frame.intersects(rect) {
                return true
            }
            if let first = sectionLayoutAttributes.items.first, let last = sectionLayoutAttributes.items.last {
                if first.frame.minX >= rect.minX {
                    if first.frame.minX < rect.maxX {
                        return true
                    }
                } else if last.frame.maxX > rect.minX {
                    return true
                }
            }
            return false
        }
        return layoutAttributes.reduce([], { (cumul, layoutAttributes) -> [UICollectionViewLayoutAttributes] in
            var res: [UICollectionViewLayoutAttributes] = cumul
            if let header = layoutAttributes.header, header.frame.intersects(rect) {
                res.append(header)
            }
            res.append(contentsOf: layoutAttributes.items.compactMap { $0.frame.intersects(rect) ? $0 : nil })
            if let footer = layoutAttributes.footer, footer.frame.intersects(rect) {
                res.append(footer)
            }
            return res
        })
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = self.collectionView else {
            return false
        }
        return newBounds.height != collectionView.bounds.height
    }
}

public extension CollectionViewHorizontalGridLayout {

    enum Defaults {
        public static let numberOfRows: Int = 1
        public static let rowSpacing: CGFloat = 0
        public static let columnSpacing: CGFloat = 0
        public static let itemWidth: CGFloat = 50
        public static let rowWeight: CGFloat = 1
        public static let sectionInset: UIEdgeInsets = .zero
    }

    struct MeasureInfo {

        public let numberOfRows: Int
        public let rowSpacing: CGFloat
        public let columnSpacing: CGFloat
        public let sectionInset: UIEdgeInsets
        public let numberOfItems: Int
        public let numberOfColumns: Int
        public let rowsHeight: [CGFloat]

        fileprivate init(section: Int, collectionView: UICollectionView, layout: CollectionViewHorizontalGridLayout) {
            let gridLayoutDelegate = collectionView.delegate as? CollectionViewDelegateHorizontalGridLayout
            self.numberOfRows = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, numberOfRowsForSection: section) ?? Defaults.numberOfRows
            self.rowSpacing = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, rowSpacingForSection: section) ?? Defaults.rowSpacing
            self.columnSpacing = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, columnSpacingForSection: section) ?? Defaults.columnSpacing
            self.sectionInset = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, insetForSection: section) ?? Defaults.sectionInset
            self.numberOfItems = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
            self.numberOfColumns = Int(ceil(Double(self.numberOfItems) / Double(self.numberOfRows)))

            guard self.numberOfRows > 0 else {
                self.rowsHeight = []
                return
            }

            let insetHeight = self.sectionInset.top + self.sectionInset.bottom
            let interItemHeight = self.rowSpacing * CGFloat(self.numberOfRows - 1)
            let availableHeight = collectionView.bounds.height - insetHeight - interItemHeight

            var weightSum: CGFloat = 0
            var rowsWeight: [CGFloat] = []
            for row in 0 ..< self.numberOfRows {
                let weight = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, weightForRow: row, inSection: section) ?? Defaults.rowWeight
                rowsWeight.append(weight)
                weightSum += weight
            }

            self.rowsHeight = rowsWeight.map { availableHeight * $0 / weightSum }
        }
    }
}
