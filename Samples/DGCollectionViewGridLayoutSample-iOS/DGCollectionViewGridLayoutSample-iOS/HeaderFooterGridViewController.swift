//
//  HeaderFooterGridViewController.swift
//  DGCollectionViewGridLayoutSample-iOS
//
//  Created by Julien Sarazin on 16/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import DGCollectionViewGridLayout

class HeaderFooterGridViewController: OriginalViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		self.configureLayout()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func configureLayout() {
		let layout = DGCollectionViewGridLayout()
		layout.lineSpacing = 10
		layout.columnSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

		self.collectionView.collectionViewLayout = layout
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
	}
}

extension HeaderFooterGridViewController: DGGridLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: DGCollectionViewGridLayout,
	                    heightForItemAtIndexPath indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
		return 80
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForHeaderInSection section: Int) -> CGFloat {
		return 42
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForFooterInSection section: Int) -> CGFloat {
		return 42
	}
}

extension HeaderFooterGridViewController: DGGridLayoutDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10

	}

	func numberOfColumnsIn(_ collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCell.Identifier, for: indexPath) as? PathCell
		cell?.set(indexPath: indexPath)
		return cell!
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("did selected item at: \(indexPath)")
	}

	func collectionView(_ collectionView: UICollectionView,
	                    viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		if let headerView: ReusableView = collectionView
			.dequeueReusableSupplementaryView(ofKind: kind,
			                                  withReuseIdentifier: ReusableView.Identifier, for: indexPath) as? ReusableView {
			headerView.textLabel.text = "\(kind)" + "(\(indexPath.section), \(indexPath.item))"
			return headerView
		}

		fatalError("Error during dequeue")
	}
}
