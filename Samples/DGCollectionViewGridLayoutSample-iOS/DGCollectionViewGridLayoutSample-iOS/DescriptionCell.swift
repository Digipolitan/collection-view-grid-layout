//
//  DescriptionCell.swift
//  DGCollectionViewGridLayoutSample-iOS
//
//  Created by Julien Sarazin on 17/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import UIKit

let longText = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, " +
"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, " +
"quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " +
"Nam liber te conscient to factor tum poen legum odioque civiuda."

let shortText = "Lorem ipsum dolor"

class DescriptionCell: UICollectionViewCell {
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet weak var innerView: UIView!
	@IBOutlet private weak var descriptionTextView: UITextView!

	static let Identifier = "DescriptionCellReuseIdentifier"
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func set(indexPath: IndexPath) {
		if indexPath.row % 2 == 0 {
			self.titleLabel.text = "short_text"
			self.descriptionTextView.text = shortText
		}
		else {
			self.titleLabel.text = "long_text"
			self.descriptionTextView.text = longText
		}
	}

	func processedHeight() -> CGFloat{
		return self.descriptionTextView.contentSize.height + self.descriptionTextView.contentInset.top + self.descriptionTextView.contentInset.bottom + self.titleLabel.bounds.height
	}
}
