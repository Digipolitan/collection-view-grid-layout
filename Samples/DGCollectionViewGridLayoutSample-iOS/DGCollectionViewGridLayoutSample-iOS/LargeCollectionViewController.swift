//
//  LargeCollectionViewController.swift
//  DGCollectionViewGridLayoutSample-iOS
//
//  Created by Julien Sarazin on 16/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import DGCollectionViewGridLayout

class LargeCollectionViewController: OriginalViewController {

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

extension LargeCollectionViewController: DGCollectionViewGridLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: DGCollectionViewGridLayout,
	                    heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
		return 80
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForHeaderIn section: Int) -> CGFloat {
		return 42
	}
}

extension LargeCollectionViewController: DGCollectionViewGridLayoutDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 5
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
		return 2000

	}

	func numberOfColumns(in collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCell.Identifier, for: indexPath) as? PathCell
		cell?.set(indexPath: indexPath)
		return cell!
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

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("did selected item at: \(indexPath)")
	}
}
