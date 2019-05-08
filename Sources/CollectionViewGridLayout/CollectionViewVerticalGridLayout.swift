//
//  CollectionViewVerticalGridLayout.swift
//  CollectionViewGridLayout
//
//  Created by Benoit BRIATTE on 05/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

@objc public protocol CollectionViewDelegateVerticalGridLayout: CollectionViewDelegateGridLayout {

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       numberOfColumnsForSection section: Int) -> Int

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       weightForColumn column: Int,
                                       inSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForItemAt indexPath: IndexPath,
                                       columnWidth: CGFloat) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForHeaderInSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForFooterInSection section: Int) -> CGFloat
}

open class CollectionViewVerticalGridLayout: UICollectionViewLayout {

    public var itemHeight: CGFloat = Defaults.itemHeight {
        didSet {
            self.invalidateLayout()
        }
    }
    fileprivate var layoutAttributes: [CollectionViewGridLayout.SectionLayoutAttributes]!
    fileprivate var contentHeight: CGFloat!

    open override func prepare() {
        super.prepare()
        self.layoutAttributes = []
        guard let collectionView = self.collectionView else {
            self.contentHeight = 0
            return
        }
        var position: CGFloat = 0
        for section in 0 ..< collectionView.numberOfSections {
            self.layoutAttributes.append(self.prepareLayoutAttributes(for: collectionView, in: section, from: &position))
        }
        self.contentHeight = position
    }

    public func prepareLayoutAttributes(for collectionView: UICollectionView, in section: Int, from position: inout CGFloat) -> CollectionViewGridLayout.SectionLayoutAttributes {
        let gridLayoutDelegate = self.collectionView?.delegate as? CollectionViewDelegateVerticalGridLayout
        var itemLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        let measureInfo = MeasureInfo(section: section, collectionView: collectionView, layout: self)
        var rowHeight: CGFloat = 0
        var columnIndex: Int = 0
        var itemFrame: CGRect = .zero
        let sectionInset = measureInfo.sectionInset
        let headerLayoutAttributes = self.prepareHeaderLayoutAttributes(for: collectionView, in: section, from: &position)
        position += sectionInset.top
        for row in 0 ..< measureInfo.numberOfRows {
            if row > 0 {
                position += measureInfo.rowSpacing
            }
            rowHeight = 0
            columnIndex = 0
            let start = row * measureInfo.numberOfColumns
            let end = min((row + 1) * measureInfo.numberOfColumns, measureInfo.numberOfItems)
            for item in start ..< end {
                if columnIndex == measureInfo.numberOfColumns {
                    columnIndex = 0
                }
                let indexPath = IndexPath(item: item, section: section)
                let itemHeight = gridLayoutDelegate?.collectionView?(collectionView, layout: self, heightForItemAt: indexPath, columnWidth: measureInfo.columnsWidth[columnIndex]) ?? self.itemHeight
                rowHeight = max(rowHeight, itemHeight)
                itemLayoutAttributes.append(UICollectionViewLayoutAttributes(forCellWith: indexPath))
                columnIndex += 1
            }
            columnIndex = 0
            var columnXPosition: CGFloat = sectionInset.left
            for item in start ..< end {
                if columnIndex == measureInfo.numberOfColumns {
                    columnIndex = 0
                }
                if columnIndex > 0 {
                    columnXPosition += measureInfo.columnSpacing
                }
                let columnWidth = measureInfo.columnsWidth[columnIndex]
                itemFrame.origin = CGPoint(x: columnXPosition, y: position)
                itemFrame.size = CGSize(width: columnWidth, height: rowHeight)
                itemLayoutAttributes[item].frame = itemFrame
                columnIndex += 1
                columnXPosition += columnWidth
            }
            position += rowHeight
        }
        position += sectionInset.bottom
        let footerLayoutAttributes = self.prepareFooterLayoutAttributes(for: collectionView, in: section, from: &position)
        return .init(items: itemLayoutAttributes, header: headerLayoutAttributes, footer: footerLayoutAttributes)
    }

    public func prepareHeaderLayoutAttributes(for collectionView: UICollectionView, in section: Int, from position: inout CGFloat) -> UICollectionViewLayoutAttributes? {
        guard let gridLayoutDelegate = self.collectionView?.delegate as? CollectionViewDelegateVerticalGridLayout else {
            return nil
        }
        let headerHeight = gridLayoutDelegate.collectionView?(collectionView, layout: self, heightForHeaderInSection: section) ?? 0
        if headerHeight > 0 {
            let headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
            headerLayoutAttributes.frame = CGRect(x: 0, y: position, width: collectionView.bounds.width, height: headerHeight)
            position += headerHeight
            return headerLayoutAttributes
        }
        return nil
    }

    public func prepareFooterLayoutAttributes(for collectionView: UICollectionView, in section: Int, from position: inout CGFloat) -> UICollectionViewLayoutAttributes? {
        guard let gridLayoutDelegate = self.collectionView?.delegate as? CollectionViewDelegateVerticalGridLayout else {
            return nil
        }
        let footerHeight = gridLayoutDelegate.collectionView?(collectionView, layout: self, heightForFooterInSection: section) ?? 0
        if footerHeight > 0 {
            let footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
            footerLayoutAttributes.frame = CGRect(x: 0, y: position, width: collectionView.bounds.width, height: footerHeight)
            position += footerHeight
            return footerLayoutAttributes
        }
        return nil
    }

    open override var collectionViewContentSize: CGSize {
        return CGSize(width: self.collectionView?.bounds.width ?? 0, height: self.contentHeight)
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
                if first.frame.minY >= rect.minY {
                    if first.frame.minY < rect.maxY {
                        return true
                    }
                } else if last.frame.maxY > rect.minY {
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
        return newBounds.width != collectionView.bounds.width
    }
}

public extension CollectionViewVerticalGridLayout {

    enum Defaults {
        public static let numberOfColumns: Int = 1
        public static let rowSpacing: CGFloat = 0
        public static let columnSpacing: CGFloat = 0
        public static let itemHeight: CGFloat = 50
        public static let columnWeight: CGFloat = 1
        public static let sectionInset: UIEdgeInsets = .zero
    }

    struct MeasureInfo {

        public let numberOfColumns: Int
        public let rowSpacing: CGFloat
        public let columnSpacing: CGFloat
        public let sectionInset: UIEdgeInsets
        public let numberOfItems: Int
        public let numberOfRows: Int
        public let columnsWidth: [CGFloat]

        fileprivate init(section: Int, collectionView: UICollectionView, layout: CollectionViewVerticalGridLayout) {
            let gridLayoutDelegate = collectionView.delegate as? CollectionViewDelegateVerticalGridLayout
            self.numberOfColumns = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, numberOfColumnsForSection: section) ?? Defaults.numberOfColumns
            self.rowSpacing = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, rowSpacingForSection: section) ?? Defaults.rowSpacing
            self.columnSpacing = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, columnSpacingForSection: section) ?? Defaults.columnSpacing
            self.sectionInset = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, insetForSection: section) ?? Defaults.sectionInset
            self.numberOfItems = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
            self.numberOfRows = Int(ceil(Double(self.numberOfItems) / Double(self.numberOfColumns)))

            guard self.numberOfColumns > 0 else {
                self.columnsWidth = []
                return
            }

            let insetWidth = self.sectionInset.left + self.sectionInset.right
            let interItemWidth = self.columnSpacing * CGFloat(self.numberOfColumns - 1)
            let availableWidth = collectionView.bounds.width - insetWidth - interItemWidth

            var weightSum: CGFloat = 0
            var columnsWeight: [CGFloat] = []
            for column in 0 ..< self.numberOfColumns {
                let weight = gridLayoutDelegate?.collectionView?(collectionView, layout: layout, weightForColumn: column, inSection: section) ?? Defaults.columnWeight
                columnsWeight.append(weight)
                weightSum += weight
            }

            self.columnsWidth = columnsWeight.map { availableWidth * $0 / weightSum }
        }
    }
}
