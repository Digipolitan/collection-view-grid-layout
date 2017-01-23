//
//  DGGridFlowLayout.swift
//  DGGridCollectionViewController
//
//  Created by Julien Sarazin on 02/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

@objc public protocol DGCollectionViewGridLayoutDataSource: UICollectionViewDataSource {
    /**
     Gives the same width for each items depending on the value returned. Default is 1.
     **/
    @objc optional func numberOfColumns(in collectionView: UICollectionView) -> Int
}

@objc public protocol DGCollectionViewGridLayoutDelegate: UICollectionViewDelegate {
    /**
     Gives the height of an item at an IndexPath. The highest item in the row will set the
     height of the row. Default is 100.
     **/
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: DGCollectionViewGridLayout,
                                       heightForItemAt indexPath: IndexPath,
                                       columnWidth: CGFloat) -> CGFloat
    /**
     Gives the height of a ReusableView of Type Header. If no height is provided,
     no header will be displayed.
     **/
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: DGCollectionViewGridLayout,
                                       heightForHeaderIn section: Int) -> CGFloat
    /**
     Gives the height of a ReusableView of Type Footer. If no height is provided,
     no footer will be displayed.
     **/
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: DGCollectionViewGridLayout,
                                       heightForFooterIn section: Int) -> CGFloat
}

/**
 Struct helping to maintain the attributes of headers and footers
 **/
fileprivate struct SupplementaryViewsInfo {
    var header: UICollectionViewLayoutAttributes?
    var footer: UICollectionViewLayoutAttributes?

    init(_ header: UICollectionViewLayoutAttributes?, _ footer: UICollectionViewLayoutAttributes?) {
        self.header = header
        self.footer = footer
    }
}

/**
 Flow Layout inhertied from the CollectionViewFlowLayout.
 It's singularity is to display and equal number of item in each line depending on
 the constraints like (section insets, spaces betwwen items, etc..)

 Also, notice that for each line, the delegate will ask the height of each items,
 this making the line height equals to the highest item in the line.
 */
open class DGCollectionViewGridLayout: UICollectionViewLayout {

    public struct Defaults {
        public static let numberOfColumns: Int = 1 // Default number of colmuns if the protocol is not implemented.
        public static let lineHeight: CGFloat = 100 // Default row height if the protocol is not implemented.
        public static let numberOfSections: Int = 1 // Default number of section, already handled by the super class.
    }

    open var sectionInset: UIEdgeInsets = UIEdgeInsets()
    open var columnSpacing: CGFloat = 0
    open var lineSpacing: CGFloat = 0
    fileprivate var numberOfSections: Int = Defaults.numberOfSections
    fileprivate var numberOfItemsInSection: [Int: Int]	= [Int: Int]()
    fileprivate var numberOfColumns: Int = Defaults.numberOfColumns
    fileprivate var numberOfLines: Int = 0
    fileprivate var numberOfLinesInSection: [Int: Int] = [Int: Int]()
    fileprivate var columnWidth: CGFloat = 0
    fileprivate var heightOfLinesInSection: [Int: [Int: CGFloat]] = [Int: [Int: CGFloat]]()
    fileprivate var supplementaryViewsInfoInSection: [Int: SupplementaryViewsInfo] = [Int: SupplementaryViewsInfo]()
    fileprivate var itemsInfoAtIndexPath: [IndexPath: UICollectionViewLayoutAttributes] = [IndexPath: UICollectionViewLayoutAttributes]()

    fileprivate var totalLinesHeight: CGFloat {
        return self.heightOfLinesInSection.reduce(0) { (totalHeight, element) -> CGFloat in
            return totalHeight + element.value.reduce(0, { (sectionHeight, heightForLine) -> CGFloat in
                return sectionHeight + heightForLine.value
            })
        }
    }

    fileprivate var totalSupplementaryViewsHeight: CGFloat {
        return self.supplementaryViewsInfoInSection.reduce(0) { (subTotal, item) -> CGFloat in
            return subTotal + (item.value.header?.size.height ?? 0) + (item.value.footer?.size.height ?? 0)
        }
    }

    fileprivate weak var delegate: DGCollectionViewGridLayoutDelegate? {
        return self.collectionView?.delegate as? DGCollectionViewGridLayoutDelegate
    }

    fileprivate weak var dataSource: DGCollectionViewGridLayoutDataSource? {
        return self.collectionView?.dataSource as? DGCollectionViewGridLayoutDataSource
    }

    // #1
    // Mandatory call to super.prepare() to let the CollectionViewFlowLayout do the initial work (sizing, positionning, etc..)
    // All global calculation about sizing and positionning should be done here.
    open override func prepare() {

        super.prepare()

        #if os(iOS)
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        #endif

        self.setNumberOfSections()
        self.setNumberOfItemsInSections()
        self.setNumberOfColumns()
        self.setColumnsWidth()
        self.setNumberOfLines()
        self.setHeightForLinesInSections()
        self.setSizeOfSupplementaryViewsInSections()
        self.setPositionForSupplementaryViews()
        self.setInfoForItemsAtIndexPath()
    }

    // #2
    // After proccessed the sizes and origins of each element contained by the CollectionView
    // we process the content size to make the content scrollable.
    open override var collectionViewContentSize: CGSize {
        let width = self.collectionView?.bounds.width ?? 0
        let height = self.estimateContentHeight()

        return CGSize(width: width, height: height)
    }

    // Get the content height by getting the height of each sections.
    fileprivate func estimateContentHeight() -> CGFloat {
        guard self.numberOfSections > 0 else {
            return 0
        }

        var height: CGFloat = 0
        for section in 0...(self.numberOfSections - 1) {
            height += self.height(forSection: section)
        }
        let collectionViewHeight = self.collectionView?.bounds.height ?? 0

        return max(collectionViewHeight, height)
    }

    // #3
    // After processed the layoutAttributes and the content size
    // The collection view will ask to its layout the element attributes to draw in a given rect.
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributesForElements(in: rect)
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemsInfoAtIndexPath[indexPath]
    }

    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = self.supplementaryViewsInfoInSection[indexPath.section] else {
            return nil
        }
        return elementKind == UICollectionElementKindSectionHeader ? attributes.header : attributes.footer
    }

    fileprivate func setNumberOfSections() {
        self.numberOfSections = self.dataSource?.numberOfSections?(in: self.collectionView!) ?? Defaults.numberOfSections
        self.numberOfSections = max(self.numberOfSections, 0)
    }

    fileprivate func setNumberOfColumns() {
        self.numberOfColumns = self.dataSource?.numberOfColumns?(in: self.collectionView!) ?? Defaults.numberOfColumns
    }

    fileprivate func setColumnsWidth() {
        let containerWidth = self.collectionView?.bounds.width ?? 0
        let insetsWidth = (self.sectionInset.left + self.sectionInset.right)
        let interItemWidth = self.columnSpacing * CGFloat(self.numberOfColumns - 1)

        let columnWidth = CGFloat(containerWidth - insetsWidth - interItemWidth) / CGFloat(self.numberOfColumns)
        self.columnWidth = max(columnWidth, 0)
    }

    fileprivate func setNumberOfLines() {
        self.numberOfLines = self.numberOfItemsInSection.reduce(0) { (subTotal, entry) -> Int in
            self.numberOfLinesInSection[entry.key] = Int(ceil(Double(entry.value) / Double(self.numberOfColumns)))
            return subTotal + self.numberOfLinesInSection[entry.key]!
        }
    }

    fileprivate func setNumberOfItemsInSections() {
        guard let collectionView = self.collectionView, self.numberOfSections > 0 else {
            return
        }

        for section in 0...(self.numberOfSections - 1) {
            self.numberOfItemsInSection[section] = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        }
    }

    fileprivate func setSizeOfSupplementaryViewsInSections() {
        guard let collectionView = self.collectionView, self.numberOfSections > 0 else {
            return
        }

        for section in 0...(self.numberOfSections - 1) {
            let headerHeight = self.delegate?.collectionView?(collectionView, layout: self, heightForHeaderIn: section) ?? 0
            let footerHeight = self.delegate?.collectionView?(collectionView, layout: self, heightForFooterIn: section) ?? 0

            let headerSize: CGSize? = headerHeight > 0 ? CGSize(width: collectionView.bounds.width, height: headerHeight) : nil
            let footerSize: CGSize? = footerHeight > 0 ? CGSize(width: collectionView.bounds.width, height: footerHeight) : nil

            var headerAttributes: UICollectionViewLayoutAttributes?
            var footerAttributes: UICollectionViewLayoutAttributes?

            if headerSize != nil {
                headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                                                    with: IndexPath(item: 0, section: section))
                headerAttributes?.frame = CGRect(x: 0, y: 0, width: (headerSize?.width ?? 0), height: (headerSize?.height ?? 0))
            }

            if footerSize != nil {
                footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                                                    with: IndexPath(item: 0, section: section))
                footerAttributes?.frame = CGRect(x: 0, y: 0, width: (footerSize?.width ?? 0), height: (footerSize?.height ?? 0))
            }

            self.supplementaryViewsInfoInSection[section] = SupplementaryViewsInfo(headerAttributes, footerAttributes)
        }
    }

    // As mentionned in the class description,
    // the line height will be equal to the highest item in the line
    fileprivate func setHeightForLinesInSections() {
        self.numberOfLinesInSection.forEach { (element) in
            let section = element.key
            let lines = Int(element.value)

            guard let collectionView = self.collectionView,
                lines > 0 else {
                    return
            }

            var linesHeight = [Int: CGFloat]()
            var lineHeight: CGFloat = 0
            for line in 0...(lines - 1) {
                lineHeight = 0
                let start = line * self.numberOfColumns
                let end = (line + 1) * self.numberOfColumns
                for item in start...(end - 1) {
                    let indexPath = IndexPath(item: item, section: section)
                    let itemHeight = self.delegate?
                        .collectionView?(collectionView, layout: self, heightForItemAt: indexPath, columnWidth: self.columnWidth) ?? Defaults.lineHeight

                    lineHeight = max(lineHeight, itemHeight)
                }
                linesHeight[line] = lineHeight
            }
            self.heightOfLinesInSection[section] = linesHeight
        }
    }

    // Set the origin of each SupplementaryView (Header and Footer)
    fileprivate func setPositionForSupplementaryViews() {
        guard self.numberOfSections > 0 else {
            return
        }

        var cumulatedHeight: CGFloat = 0
        for section in 0...(self.numberOfSections - 1) {
            cumulatedHeight += self.height(forSection: section - 1)
            let headerOrigin = CGPoint(x: 0, y: cumulatedHeight)

            let linesHeight = self.heightOfLines(in: section)
            let insets = self.sectionInset.top + self.sectionInset.bottom
            let header = self.supplementaryViewsInfoInSection[section]?.header?.size.height ?? 0

            let footerOrigin = CGPoint(x: 0, y: cumulatedHeight + linesHeight + insets + header)

            if let info = self.supplementaryViewsInfoInSection[section] {
                info.header?.frame.origin = headerOrigin
                info.footer?.frame.origin = footerOrigin

                self.supplementaryViewsInfoInSection[section] = info
            }
        }
    }

    // Set the origin of each item
    fileprivate func setInfoForItemsAtIndexPath() {
        guard self.numberOfSections > 0 else {
            return
        }

        for section in 0...(self.numberOfSections - 1) {

            guard let items = self.numberOfItemsInSection[section],
                items > 0 else {
                    continue
            }

            for item in 0...(items - 1) {
                let indexPath = IndexPath(item: item, section: section)
                let lineIndex = self.lineIndex(from: indexPath)
                let x = self.xAxis(for: item)
                let y = self.yAxis(for: lineIndex, in: section)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: x,
                                          y: y,
                                          width: self.columnWidth,
                                          height: self.heightOfLinesInSection[section]?[lineIndex] ?? Defaults.lineHeight)
                self.itemsInfoAtIndexPath[indexPath] = attributes
            }
        }
    }
}

// Utility functions
extension DGCollectionViewGridLayout {
    fileprivate func attributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var attributesCollection: [UICollectionViewLayoutAttributes] = []

        let itemAttributes = self.itemsInfoAtIndexPath.flatMap { (element) -> UICollectionViewLayoutAttributes? in
            return element.value.frame.intersects(rect) ? element.value : nil
        }

        var supplementaryViewsAttributes: [UICollectionViewLayoutAttributes] = []
        self.supplementaryViewsInfoInSection.forEach { (element) in
            if let attributes = element.value.header {
                supplementaryViewsAttributes.append(attributes)
            }

            if let attributes = element.value.footer {
                supplementaryViewsAttributes.append(attributes)
            }
        }

        attributesCollection.append(contentsOf: itemAttributes)
        attributesCollection.append(contentsOf: supplementaryViewsAttributes)

        return attributesCollection
    }

    fileprivate func totalOffsetFromSupplementaryViews(at section: Int) -> CGFloat {

        guard section > 0 else {
            return self.supplementaryViewsInfoInSection[0]?.header?.size.height ?? 0
        }

        var offset: CGFloat = 0
        for index in 0...(section - 1) {
            let suppOffset = self.supplementaryViewsInfoInSection[index]
            offset += (suppOffset?.header?.size.height ?? 0) + (suppOffset?.footer?.size.height ?? 0)
        }

        return offset
    }

    fileprivate func lineIndex(from indexPath: IndexPath) -> Int {
        return indexPath.row / self.numberOfColumns
    }

    fileprivate func heightOfLines(in section: Int) -> CGFloat {
        guard let lines = self.heightOfLinesInSection[section] else {
            return self.lineSpacing
        }

        let linesHeight = lines.reduce(0, { (subTotal, element) -> CGFloat in
            return subTotal + element.value
        })

        let lineSpacing = CGFloat(lines.count - 1) * self.lineSpacing

        return linesHeight + lineSpacing
    }

    fileprivate func height(forSection section: Int) -> CGFloat {
        guard section >= 0 else {
            return 0
        }

        let offset = self.supplementaryViewsInfoInSection[section]
        let insets = self.sectionInset.top + self.sectionInset.bottom
        return self.heightOfLines(in: section)
            + (offset?.header?.size.height ?? 0)
            + (offset?.footer?.size.height ?? 0)
            + insets
    }

    fileprivate func yAxis(for line: Int, in section: Int) -> CGFloat {
        var offset: CGFloat = 0

        for index in 0...section {
            offset += self.height(forSection: index - 1)
        }

        offset += (self.supplementaryViewsInfoInSection[section]?.header?.size.height ?? 0) + self.sectionInset.top

        if line > 0 {
            for index in 0...(line - 1) {
                offset += self.heightOfLinesInSection[section]![index]! + self.lineSpacing
            }
        }

        return offset
    }

    fileprivate func xAxis(for item: Int) -> CGFloat {
        if item % self.numberOfColumns == 0 {
            return self.sectionInset.left
        } else {
            return self.xAxis(for: item - 1)
                + self.columnWidth
                + self.columnSpacing
        }
    }
}

#if os(iOS)
    extension DGCollectionViewGridLayout {
        @objc
        fileprivate func rotated () {
            self.invalidateLayout()
        }
    }
#endif
