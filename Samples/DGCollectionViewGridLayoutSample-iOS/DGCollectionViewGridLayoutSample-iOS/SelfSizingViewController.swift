//
//  SelfSizingViewController.swift
//  DGCollectionViewGridLayoutSample-iOS
//
//  Created by Julien Sarazin on 17/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import DGCollectionViewGridLayout

class SelfSizingViewController: OriginalViewController {
	var prototype: DescriptionCell? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		self.collectionView.register(UINib(nibName: String(describing: DescriptionCell.self), bundle: nil), forCellWithReuseIdentifier: DescriptionCell.Identifier)

		self.initPrototype()
		self.configureLayout()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func initPrototype() {
		self.prototype = Bundle.main.loadNibNamed(String(describing: DescriptionCell.self), owner: self, options: nil)!.first as? DescriptionCell
	}

	func configureLayout() {
		let layout = DGCollectionViewGridLayout()
		layout.lineSpacing = 1
		layout.columnSpacing = 0
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

		self.collectionView.collectionViewLayout = layout
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
	}
}

extension SelfSizingViewController: DGCollectionViewGridLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: DGCollectionViewGridLayout,
	                    heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
		return 150
	}
}

extension SelfSizingViewController: DGCollectionViewGridLayoutDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10

	}

	func numberOfColumns(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DescriptionCell.Identifier, for: indexPath) as? DescriptionCell
		cell?.set(indexPath: indexPath)
		return cell!
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("did selected item at: \(indexPath)")
	}
}
