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
		self.collectionView!.register(UINib(nibName: String(describing: PathCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: PathCell.Identifier)

		self.collectionView.register(UINib(nibName:String(describing:ReusableView.self), bundle:Bundle.main),
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: ReusableView.Identifier)

		self.collectionView.register(UINib(nibName:String(describing: ReusableView.self), bundle:Bundle.main),
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
		                             withReuseIdentifier: ReusableView.Identifier)

		self.collectionView.delegate = self
		self.collectionView.dataSource = self

		self.collectionView.collectionViewLayout = DGCollectionViewGridLayout()
		(self.collectionView.collectionViewLayout as? DGCollectionViewGridLayout)!.lineSpacing = 10
		(self.collectionView.collectionViewLayout as? DGCollectionViewGridLayout)!.interitemSpacing = 10
		(self.collectionView.collectionViewLayout as? DGCollectionViewGridLayout)!.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}


extension DemoViewController: DGGridLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForFooterInSection section: Int) -> CGFloat {
		return 40
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForItemAtIndexPath indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
		return 70
	}
}


extension DemoViewController: DGGridLayoutDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 100
	}

	func numberOfColumnsIn(_ collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCell.Identifier, for: indexPath) as? PathCell
		cell?.textLabrel.text = "(\(indexPath.section), \(indexPath.item))"
		cell?.contentView.backgroundColor = indexPath.item % 2 == 0 ? .purple : .lightGray
		return cell!
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let headerView: ReusableView = (collectionView.dequeueReusableSupplementaryView(ofKind: kind,
		                                                                                withReuseIdentifier: ReusableView.Identifier, for: indexPath) as? ReusableView)!

		headerView.textLabel.text = "\(kind)" + "(\(indexPath.section), \(indexPath.item))"
		return headerView
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("selected item: \(indexPath)")
	}
}
