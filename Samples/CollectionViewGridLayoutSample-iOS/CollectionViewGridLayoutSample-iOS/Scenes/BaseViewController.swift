//
//  BaseViewController.swift
//  CollectionViewGridLayoutSample-iOS
//
//  Created by Benoit BRIATTE on 07/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

public class BaseViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: String(describing: PathCollectionViewCell.self), bundle: nil),
                                      forCellWithReuseIdentifier: PathCollectionViewCell.identifier)

        self.collectionView.register(UINib(nibName: String(describing: CollectionReusableView.self), bundle: nil),
                                     forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: CollectionReusableView.identifier)

        self.collectionView.register(UINib(nibName: String(describing: CollectionReusableView.self), bundle: nil),
                                     forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                     withReuseIdentifier: CollectionReusableView.identifier)
    }
}
