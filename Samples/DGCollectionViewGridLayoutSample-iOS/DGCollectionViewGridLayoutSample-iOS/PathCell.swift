//
//  PathCell.swift
//  DGGridCollectionViewControllerSample-iOS
//
//  Created by Julien Sarazin on 03/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

private let kReuseIdentifier = "ReuseIdentifier"

class PathCell: UICollectionViewCell {
	@IBOutlet private weak var textLabrel: UILabel!
	@IBOutlet private weak var collectionView: UICollectionView!

	fileprivate var indexPath: IndexPath?
	fileprivate var numberOfSection: Int = 0
	fileprivate var numberOfRow: Int = 0

	@IBOutlet weak var widthConstraint: NSLayoutConstraint!
	static let Identifier: String = "PathCellReuseIdentifier"

	override func awakeFromNib() {
		super.awakeFromNib()
		self.collectionView.delegate = self
		self.collectionView.dataSource = self

		let layout: UICollectionViewFlowLayout = (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)!


		self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kReuseIdentifier)
	}

	func set(indexPath: IndexPath) {
		self.numberOfSection = indexPath.section
		self.numberOfRow = indexPath.row
		self.indexPath = indexPath

		self.textLabrel.text = "[\(indexPath.section), \(indexPath.item)]"
		self.collectionView.reloadData()
	}

	func estimatedHeight(estimatedWidth: CGFloat) -> CGFloat {
		self.collectionView.collectionViewLayout.invalidateLayout()
		self.collectionView.layoutIfNeeded()
		let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
		print("content: \(self.collectionView.frame.width)")
		print("width: \(self.collectionView.frame.width)")
		return contentSize.height + self.textLabrel.frame.height + 10
	}
}

extension PathCell : UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (self.numberOfSection + 1) * self.numberOfRow
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kReuseIdentifier, for: indexPath)
		cell.backgroundColor = (indexPath.section % 2 == 0) ? .blue : .yellow
		return cell
	}
}

extension PathCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 50, height: 50)
	}
}
