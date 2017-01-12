//
//  SimpleCollectionViewController.swift
//  DGGridCollectionViewControllerSample-iOS
//
//  Created by Julien Sarazin on 03/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import DGCollectionViewGridLayout

class DemoViewController: UIViewController {
	@IBOutlet weak var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Demo"
		self.collectionView!.register(UINib(nibName: String(describing: PathCell.self),
		                                    bundle: Bundle.main),
		                              forCellWithReuseIdentifier: PathCell.Identifier)

		self.collectionView.register(UINib(nibName:String(describing:ReusableView.self), bundle:Bundle.main),
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: ReusableView.Identifier)

		self.collectionView.register(UINib(nibName:String(describing: ReusableView.self), bundle:Bundle.main),
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
		                             withReuseIdentifier: ReusableView.Identifier)

		self.collectionView.delegate = self
		self.collectionView.dataSource = self

		let layout =  DGCollectionViewGridLayout()
		layout.lineSpacing = 10
//		layout.columnSpacing = 10
//		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

		self.collectionView.collectionViewLayout = layout
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension DemoViewController: DGGridLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: DGCollectionViewGridLayout,
	                    heightForFooterInSection section: Int) -> CGFloat {
		return 40
	}

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: DGCollectionViewGridLayout,
	                    heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: DGCollectionViewGridLayout,
	                    heightForItemAtIndexPath indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {

		let prototype: PathCell = (Bundle.main.loadNibNamed(String(describing: PathCell.self), owner: self, options: nil)!.first as? PathCell)!
		prototype.set(indexPath: indexPath)
		return prototype.estimatedHeight(estimatedWidth: columnWidth)
	}
}

extension DemoViewController: DGGridLayoutDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 0

	}

//	func numberOfColumnsIn(_ collectionView: UICollectionView) -> Int {
//		return 3
//	}

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
		print("selected item: \(indexPath)")
	}
}
