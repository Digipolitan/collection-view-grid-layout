//
//  HorizontalClassicViewController.swift
//  CollectionViewGridLayoutSample-iOS
//
//  Created by Benoit BRIATTE on 07/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import CollectionViewGridLayout

public class HorizontalClassicViewController: BaseViewController {

    public var numberOfRows: Int = 5

    @IBAction func addColumn(_ sender: UIBarButtonItem) {
        self.numberOfRows += 1
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        })
    }

    @IBAction func removeColumn(_ sender: UIBarButtonItem) {
        if self.numberOfRows > 1 {
            self.numberOfRows -= 1
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadData()
            })
        }
    }
}

extension HorizontalClassicViewController: CollectionViewDelegateHorizontalGridLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, rowSpacingForSection section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnSpacingForSection section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, widthForItemAt indexPath: IndexPath, rowHeight columnHeight: CGFloat) -> CGFloat {
        return 80
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, widthForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfRowsForSection section: Int) -> Int {
        return self.numberOfRows
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select [\(indexPath.section), \(indexPath.row)]")
    }
}

extension HorizontalClassicViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCollectionViewCell.identifier, for: indexPath) as? PathCollectionViewCell else {
            fatalError("Cannot retrieve PathCollectionViewCell")
        }
        cell.setIndexPath(indexPath)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableView.identifier, for: indexPath) as? CollectionReusableView else {
            fatalError("Cannot retrieve CollectionReusableView")
        }
        view.setIndexPath(indexPath, kind: kind)
        return view
    }
}
