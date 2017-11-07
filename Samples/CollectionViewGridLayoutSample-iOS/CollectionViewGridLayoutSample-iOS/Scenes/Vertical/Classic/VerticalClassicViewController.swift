//
//  VerticalClassicViewController.swift
//  CollectionViewGridLayoutSample-iOS
//
//  Created by Benoit BRIATTE on 07/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import CollectionViewGridLayout

public class VerticalClassicViewController: BaseViewController {

    public var numberOfColumns: Int = 5

    @IBAction func addColumn(_ sender: UIBarButtonItem) {
        self.numberOfColumns += 1
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        })
    }

    @IBAction func removeColumn(_ sender: UIBarButtonItem) {
        if self.numberOfColumns > 1 {
            self.numberOfColumns -= 1
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadData()
            })
        }
    }
}

extension VerticalClassicViewController: CollectionViewDelegateVerticalGridLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, rowSpacingForSection section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnSpacingForSection section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
        return 80
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select [\(indexPath.section), \(indexPath.row)]")
    }
}

extension VerticalClassicViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsForSection section: Int) -> Int {
        return self.numberOfColumns
    }

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
