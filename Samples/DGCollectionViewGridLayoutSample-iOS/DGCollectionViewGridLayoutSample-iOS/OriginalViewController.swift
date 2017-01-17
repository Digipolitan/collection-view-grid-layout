//
//  SimpleCollectionViewController.swift
//  DGGridCollectionViewControllerSample-iOS
//
//  Created by Julien Sarazin on 03/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import DGCollectionViewGridLayout

class OriginalViewController: UIViewController {
	@IBOutlet weak var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.collectionView!.register(UINib(nibName: String(describing: PathCell.self),
		                                    bundle: Bundle.main),
		                              forCellWithReuseIdentifier: PathCell.Identifier)

		self.collectionView.register(UINib(nibName:String(describing:ReusableView.self), bundle:Bundle.main),
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: ReusableView.Identifier)

		self.collectionView.register(UINib(nibName:String(describing: ReusableView.self), bundle:Bundle.main),
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
		                             withReuseIdentifier: ReusableView.Identifier)
	}
}
