//
//  DGGridFlowLayout.swift
//  DGGridCollectionViewController
//
//  Created by Julien Sarazin on 02/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

@objc public protocol DGGridLayoutDataSource: UICollectionViewDataSource {
	/**
	Gives the same width for each items depending on the value returned. Default is 1.
	**/
	@objc optional func numberOfColumnsIn(_ collectionView: UICollectionView) -> Int
}

@objc public protocol DGGridLayoutDelegate: UICollectionViewDelegate {
	/**
	Gives the height of an item at an IndexPath. The highest item in the row will set the 
	height of the row. Default is 100.
	**/
	@objc optional func collectionView(_ collectionView: UICollectionView,
	                                          layout collectionViewLayout: DGCollectionViewGridLayout,
	                                          heightForItemAtIndexPath indexPath: IndexPath,
	                                          columnWidth: CGFloat) -> CGFloat
	/**
	Gives the height of a ReusableView of Type Header. If no height is provided,
	no header will be displayed.
	**/
	@objc optional func collectionView(_ collectionView: UICollectionView,
	                                          layout collectionViewLayout: DGCollectionViewGridLayout,
	                                          heightForHeaderInSection section: Int) -> CGFloat
	/**
	Gives the height of a ReusableView of Type Footer. If no height is provided,
	no footer will be displayed.
	**/
	@objc optional func collectionView(_ collectionView: UICollectionView,
	                                          layout collectionViewLayout: DGCollectionViewGridLayout,
	                                          heightForFooterInSection section: Int) -> CGFloat
}

fileprivate let kDefaultColumns: Int	= 1		// Default number of colmuns if the protocol is not implemented.
fileprivate let kDefaultHeight: CGFloat	= 100	// Default row height if the protocol is not implemented.
fileprivate let kDefaultSections: Int	= 1		// Default number of section, already handled by the super class.

/**
Struct helping to maintain the attributes of headers and footers
**/
fileprivate struct SupplementaryViewsInfo {
	var header: UICollectionViewLayoutAttributes?
	var footer: UICollectionViewLayoutAttributes?

	init(_ header: UICollectionViewLayoutAttributes, _ footer: UICollectionViewLayoutAttributes) {
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
	open var sectionInset: UIEdgeInsets = UIEdgeInsets()
	open var columnSpacing: CGFloat = 0
	open var lineSpacing: CGFloat = 0

	fileprivate var numberOfSections: Int = kDefaultSections
	fileprivate var numberOfItemsInSection: [Int: Int]	= [Int: Int]()
	fileprivate var numberOfColumns: Int = kDefaultColumns
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

	fileprivate weak var delegate: DGGridLayoutDelegate? {
		return self.collectionView?.delegate as? DGGridLayoutDelegate
	}

	fileprivate weak var dataSource: DGGridLayoutDataSource? {
		return self.collectionView?.dataSource as? DGGridLayoutDataSource
	}

	// #1
	// Mandatory call to super.prepare() to let the CollectionViewFlowLayout do the initial work (sizing, positionning, etc..)
	// All global calculation about sizing and positionning should be done here.
	open override func prepare() {
		super.prepare()

		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

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
		let width = self.collectionView!.bounds.width
		let height = self.estimateContentHeight()

		return CGSize(width: width, height: height)
	}

	// Get the content height by getting the height of each sections.
	fileprivate func estimateContentHeight() -> CGFloat {
		var height: CGFloat = 0

		guard self.numberOfSections > 0 else {
			return height
		}
		
		for section in 0...(self.numberOfSections - 1) {
			height = height + self.getHeightOf(section: section)
		}

		return max(self.collectionView!.bounds.height, height)
	}

	// #3
	// After processed the layoutAttributes and the content size 
	// The collection view will ask to its layout the element attributes to draw in a given rect.
	open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return self.getAttributesForElementIn(rect: rect)
	}

	open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return self.itemsInfoAtIndexPath[indexPath]
	}

	open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = self.supplementaryViewsInfoInSection[indexPath.section]!
		return elementKind == UICollectionElementKindSectionHeader ? attributes.header : attributes.footer
	}

	fileprivate func setNumberOfSections() {
		self.numberOfSections = self.dataSource?.numberOfSections?(in: self.collectionView!) ?? kDefaultSections
		self.numberOfSections = max(self.numberOfSections, 0)
	}

	fileprivate func setNumberOfColumns() {
		self.numberOfColumns = self.dataSource?.numberOfColumnsIn?(self.collectionView!) ?? kDefaultColumns
	}

	fileprivate func setColumnsWidth() {
		let containerWidth = self.collectionView!.bounds.width
		let insetsWidth = (self.sectionInset.left + self.sectionInset.right)
		let interItemWidth = self.columnSpacing * CGFloat(self.numberOfColumns - 1)

		self.columnWidth = CGFloat(containerWidth - insetsWidth - interItemWidth) / CGFloat(self.numberOfColumns)
	}

	fileprivate func setNumberOfLines() {
		self.numberOfLines = self.numberOfItemsInSection.reduce(0) { (subTotal, entry) -> Int in
			self.numberOfLinesInSection[entry.key] = Int(ceil(Double(entry.value) / Double(self.numberOfColumns)))
			return subTotal + self.numberOfLinesInSection[entry.key]!
		}
	}

	fileprivate func setNumberOfItemsInSections() {
		guard self.numberOfSections > 0 else {
			return
		}

		for section in 0...(self.numberOfSections - 1) {
			self.numberOfItemsInSection[section] = self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: section) ?? 0
		}
	}

	fileprivate func setSizeOfSupplementaryViewsInSections() {
		guard self.numberOfSections > 0 else {
			return
		}

		for section in 0...(self.numberOfSections - 1) {
			let headerHeight = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForHeaderInSection: section) ?? 0
			let footerHeight = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForFooterInSection: section) ?? 0

			let headerSize: CGSize? = CGSize(width: (self.collectionView?.bounds.width ?? 0), height: headerHeight)
			let footerSize: CGSize? = CGSize(width: (self.collectionView?.bounds.width ?? 0), height: footerHeight)

			if let info = self.supplementaryViewsInfoInSection[section] {
				info.header?.size = headerSize ?? CGSize()
				info.footer?.size = footerSize ?? CGSize()
			}
			else {
				let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
				                                                       with: IndexPath(item: 0, section: section))
				headerAttributes.frame = CGRect(x: 0, y: 0, width: (headerSize?.width ?? 0), height: (headerSize?.height ?? 0))

				let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
				                                                        with: IndexPath(item: 0, section: section))

				 footerAttributes.frame = CGRect(x: 0, y: 0, width: (footerSize?.width ?? 0), height: (footerSize?.height ?? 0))

				self.supplementaryViewsInfoInSection[section] = SupplementaryViewsInfo(headerAttributes, footerAttributes)
			}
		}
	}

	// As mentionned in the class description,
	// the line height will be equal to the highest item in the line
	fileprivate func setHeightForLinesInSections() {
		self.numberOfLinesInSection.forEach { (element) in
			let section = element.key
			let lines = Int(element.value)

			guard lines > 0 else {
				return
			}

			for line in 0...(lines - 1) {
				var lineHeight: CGFloat = 0
				let start = max(0, line - 1) * self.numberOfColumns
				let end = (line + 1) * self.numberOfColumns
				for item in start...(end - 1) {
//					print("item: \(item), line: \(line), section: \(section)")
					let indexPath = IndexPath(item: ((line * self.numberOfColumns) + item), section: section)

					let itemHeight = self.delegate?
						.collectionView?(self.collectionView!, layout: self, heightForItemAtIndexPath: indexPath, columnWidth: self.columnWidth) ?? kDefaultHeight

					lineHeight = max(lineHeight, itemHeight)
				}
				if var linesHeight = self.heightOfLinesInSection[section] {
					linesHeight[line] = lineHeight
					self.heightOfLinesInSection[section] = linesHeight
				}
				else {
					self.heightOfLinesInSection[section] = [line: lineHeight]
				}
			}
		}
	}

	// Set the origin of each SupplementaryView (Header and Footer)
	fileprivate func setPositionForSupplementaryViews() {
		guard self.numberOfSections > 0 else {
			return
		}

		var cumulatedHeight: CGFloat = 0
		for section in 0...(self.numberOfSections - 1) {
			cumulatedHeight = cumulatedHeight + self.getHeightOf(section: section - 1)
			let headerOrigin = CGPoint(x: 0, y: cumulatedHeight)

			let linesHeights = self.getHeightOfLinesIn(section: section)
			let insets = self.sectionInset.top + self.sectionInset.bottom
			let header = (self.supplementaryViewsInfoInSection[section]?.header?.size.height ?? 0)

			let footerOrigin = CGPoint(x: 0, y: cumulatedHeight + linesHeights + insets + header)

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
			let items = self.numberOfItemsInSection[section]!

			guard items > 0 else {
				continue
			}

			for item in 0...(items - 1) {
				let indexPath = IndexPath(item: item, section: section)
				let line = self.getLineFrom(indexPath: indexPath)
				let x = self.getXAxisFor(item: item)
				let y = self.getYAxisFor(line: line, in: section)

				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = CGRect(x: x,
				                          y: y,
				                          width: self.columnWidth,
				                          height: self.heightOfLinesInSection[section]![line]!)
				self.itemsInfoAtIndexPath[indexPath] = attributes
			}
		}
	}
}

// Utility functions
extension DGCollectionViewGridLayout {
	fileprivate func getAttributesForElementIn(rect: CGRect) -> [UICollectionViewLayoutAttributes] {
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

	fileprivate func getTotalOffsetFromSupplementaryViewsAtSection(section: Int) -> CGFloat {
		var offset: CGFloat = 0

		guard section > 0 else {
			return self.supplementaryViewsInfoInSection[0]?.header?.size.height ?? 0
		}

		for index in 0...(section - 1) {
			let suppOffset = self.supplementaryViewsInfoInSection[index]
			offset = offset + (suppOffset?.header?.size.height ?? 0) + (suppOffset?.footer?.size.height ?? 0)
		}

		return offset
	}

	fileprivate func getLineFrom(indexPath: IndexPath) -> Int {
		let line = indexPath.row / self.numberOfColumns
		return line
	}

	fileprivate func getHeightOfLinesIn(section: Int) -> CGFloat {
		guard let lines = self.heightOfLinesInSection[section] else {
			return self.lineSpacing
		}

		let linesHeight = lines.reduce(0, { (subTotal, element) -> CGFloat in
			return subTotal + element.value
		})

		let lineSpacing = CGFloat(lines.count - 1) * self.lineSpacing

		return linesHeight + lineSpacing
	}

	fileprivate func getHeightOf(section: Int) -> CGFloat {
		guard section >= 0 else {
			return 0
		}

		let offset = self.supplementaryViewsInfoInSection[section]
		let insets = self.sectionInset.top + self.sectionInset.bottom
		return self.getHeightOfLinesIn(section: section)
			+ (offset?.header?.size.height ?? 0)
			+ (offset?.footer?.size.height ?? 0)
			+ insets
	}

	fileprivate func getYAxisFor(line: Int, `in` section: Int) -> CGFloat {
		var offset: CGFloat = 0

		for index in 0...section {
			offset = offset + self.getHeightOf(section: index - 1)
		}

		offset = offset
			+ (self.supplementaryViewsInfoInSection[section]?.header?.size.height ?? 0)
			+ self.sectionInset.top

		if line > 0 {
			for index in 0...(line - 1) {
				offset = offset
					+ self.heightOfLinesInSection[section]![index]!
					+ self.lineSpacing
			}
		}

		return offset
	}

	fileprivate func getXAxisFor(item: Int) -> CGFloat {
		if item % self.numberOfColumns == 0 {
			return self.sectionInset.left
		}
		else {
			return self.getXAxisFor(item: item - 1)
				+ self.columnWidth
				+ self.columnSpacing
		}
	}
}

extension DGCollectionViewGridLayout {
	@objc
	fileprivate func rotated () {
		self.invalidateLayout()
	}
}
