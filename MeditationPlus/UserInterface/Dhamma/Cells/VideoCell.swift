//
//  VideoCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/11/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPVideoCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoImageViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageCenterConstraint: NSLayoutConstraint!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        clipsToBounds = true

        videoImageView.transform = CGAffineTransformMakeScale(1.5, 1.5)
        selectionStyle = UITableViewCellSelectionStyle.None
    }

    func setParallaxFactor(factor: CGFloat)
    {
        videoImageCenterConstraint.constant = factor * -80
    }
}
