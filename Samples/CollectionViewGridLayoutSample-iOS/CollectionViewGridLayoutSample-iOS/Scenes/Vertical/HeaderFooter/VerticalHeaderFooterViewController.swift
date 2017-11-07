//
//  VerticalHeaderFooterViewController.swift
//  CollectionViewGridLayoutSample-iOS
//
//  Created by Benoit BRIATTE on 07/11/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit
import CollectionViewGridLayout

public class VerticalHeaderFooterViewController: BaseViewController { }

extension VerticalHeaderFooterViewController: CollectionViewDelegateVerticalGridLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
        return 80
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select [\(indexPath.section), \(indexPath.row)]")
    }
}

extension VerticalHeaderFooterViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsForSection section: Int) -> Int {
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
